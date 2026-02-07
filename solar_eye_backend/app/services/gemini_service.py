"""
Solar Eye Backend - Gemini AI Service

Gemini API를 활용한 AI 일일 브리핑 생성 서비스
"""

import json
import logging
from datetime import datetime
from typing import Any, Optional

import google.generativeai as genai

from app.config import settings

logger = logging.getLogger(__name__)


class GeminiService:
    """Gemini AI 서비스 클래스"""

    def __init__(self):
        """Gemini API 초기화"""
        if not settings.gemini_api_key:
            logger.warning("Gemini API key is not configured")
            self._initialized = False
            return

        genai.configure(api_key=settings.gemini_api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash')
        self._initialized = True
        logger.info("Gemini AI service initialized successfully")

    @property
    def is_available(self) -> bool:
        """Gemini 서비스 사용 가능 여부"""
        return self._initialized

    async def generate_daily_briefing(
        self,
        date: str,
        summary: dict[str, Any],
        anomalies: list[str],
        weather_forecast: dict[str, Any],
        economic_loss: str,
    ) -> dict[str, Any]:
        """
        일일 AI 브리핑 생성

        Args:
            date: 리포트 날짜 (YYYY-MM-DD)
            summary: 탐지 요약 {'total': int, 'normal': int, 'soiling': int, 'crack': int}
            anomalies: 특이사항 목록
            weather_forecast: 내일 날씨 예보 {'condition': str, 'precipitation': int}
            economic_loss: 예상 경제 손실 문자열

        Returns:
            AI 솔루션 딕셔너리 {
                'solution_type': 'good'|'caution'|'danger',
                'title': str,
                'content': str,
                'action_items': list[str]
            }
        """
        if not self._initialized:
            logger.warning("Gemini service not initialized, returning default response")
            return self._get_default_response(summary, anomalies)

        try:
            prompt = self._build_prompt(date, summary, anomalies, weather_forecast, economic_loss)
            
            response = await self.model.generate_content_async(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.7,
                    max_output_tokens=500,
                )
            )

            return self._parse_response(response.text)

        except Exception as e:
            logger.error(f"Gemini API error: {e}")
            return self._get_default_response(summary, anomalies)

    def _build_prompt(
        self,
        date: str,
        summary: dict[str, Any],
        anomalies: list[str],
        weather_forecast: dict[str, Any],
        economic_loss: str,
    ) -> str:
        """프롬프트 생성"""
        
        system_instruction = """당신은 태양광 발전소 관리 전문가입니다.
주어진 데이터를 분석하여 관리자에게 보낼 '일일 리포트 코멘트'를 작성하세요.

**중요 규칙:**
1. 내일 날씨를 고려하여 청소/수리/대기 중 하나를 명확히 권고하세요.
2. 경제적 손실 금액을 언급하여 행동의 필요성을 강조하세요.
3. 비가 예보되면 자연 세척 효과를 고려하여 청소 연기를 권고하세요.
4. 파손(crack)이 있으면 반드시 긴급 점검을 권고하세요.
5. 한국어로 친절하고 전문적인 톤으로 작성하세요.

**응답 형식 (반드시 JSON으로만 응답):**
{
    "solution_type": "good 또는 caution 또는 danger 중 하나",
    "title": "한줄 요약 (20자 이내, 이모지 포함 가능)",
    "content": "상세 설명 (100-200자)",
    "action_items": ["구체적 행동 1", "구체적 행동 2"]
}

**solution_type 기준:**
- good: 특이사항 없음, 정상 가동
- caution: 오염 발견, 청소 권장
- danger: 파손 발견, 긴급 점검 필요"""

        # 특이사항 문자열
        anomalies_text = "\n".join(f"- {a}" for a in anomalies) if anomalies else "- 특이사항 없음"
        
        # 날씨 정보
        condition = weather_forecast.get("condition", "맑음")
        precipitation = weather_forecast.get("precipitation", 0)

        user_prompt = f"""
오늘 날짜: {date}

[탐지 요약]
- 총 탐지: {summary.get('total', 0)}건
- 정상: {summary.get('normal', 0)}건
- 오염: {summary.get('soiling', 0)}건
- 파손: {summary.get('crack', 0)}건

[특이사항]
{anomalies_text}

[내일 날씨 예보]
- 상태: {condition}
- 강수 확률: {precipitation}%

[예상 경제 손실]
{economic_loss}

위 데이터를 분석하여 JSON 형식으로만 응답해주세요."""

        return f"{system_instruction}\n\n{user_prompt}"

    def _parse_response(self, response_text: str) -> dict[str, Any]:
        """Gemini 응답 파싱"""
        try:
            # JSON 부분만 추출 (마크다운 코드블록 제거)
            text = response_text.strip()
            
            # ```json ... ``` 형식 처리
            if "```json" in text:
                text = text.split("```json")[1].split("```")[0].strip()
            elif "```" in text:
                text = text.split("```")[1].split("```")[0].strip()

            result = json.loads(text)

            # 필수 필드 검증
            return {
                "solution_type": result.get("solution_type", "good"),
                "title": result.get("title", "분석 완료"),
                "content": result.get("content", "분석이 완료되었습니다."),
                "action_items": result.get("action_items", []),
            }

        except (json.JSONDecodeError, KeyError) as e:
            logger.error(f"Failed to parse Gemini response: {e}, response: {response_text}")
            return {
                "solution_type": "good",
                "title": "🟢 분석 완료",
                "content": "오늘의 분석이 완료되었습니다.",
                "action_items": [],
            }

    def _get_default_response(
        self,
        summary: dict[str, Any],
        anomalies: list[str],
    ) -> dict[str, Any]:
        """기본 응답 생성 (API 실패 시)"""
        
        crack_count = summary.get("crack", 0)
        soiling_count = summary.get("soiling", 0)
        
        if crack_count > 0:
            return {
                "solution_type": "danger",
                "title": "🚨 긴급 점검 필요",
                "content": f"오늘 {crack_count}건의 파손이 감지되었습니다. 현장 점검을 권장합니다.",
                "action_items": ["현장 육안 점검 수행", "파손 패널 위치 확인"],
            }
        elif soiling_count > 5:
            return {
                "solution_type": "caution",
                "title": "😐 청소를 권장합니다",
                "content": f"오늘 {soiling_count}건의 오염이 감지되었습니다. 발전 효율 저하가 예상됩니다.",
                "action_items": ["패널 청소 일정 확인", "오염 구역 집중 점검"],
            }
        else:
            return {
                "solution_type": "good",
                "title": "🟢 발전소가 건강합니다",
                "content": "오늘 특별한 이상이 발견되지 않았습니다. 모든 패널이 정상 가동 중입니다.",
                "action_items": [],
            }


# 싱글톤 인스턴스
_gemini_service: Optional[GeminiService] = None


def get_gemini_service() -> GeminiService:
    """Gemini 서비스 인스턴스 반환"""
    global _gemini_service
    if _gemini_service is None:
        _gemini_service = GeminiService()
    return _gemini_service
