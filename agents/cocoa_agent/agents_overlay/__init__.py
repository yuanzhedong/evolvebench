# Harbor overlay: only export CocoaAgent to avoid loading GeminiDeepResearchAgent
# (which requires decrypt_utils not needed for our use case).
"""Agent implementations for Harbor (CocoaAgent only)."""
from .base import BaseAgent
from .cocoa_agent import CocoaAgent

__all__ = ["BaseAgent", "CocoaAgent"]
