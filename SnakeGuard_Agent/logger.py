import logging
import sys
import os

def setup_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    
    log_level_str = os.getenv("LOG_LEVEL", "INFO").upper()
    log_level = getattr(logging, log_level_str, logging.INFO)
    
    logger.setLevel(log_level)
    
    # Avoid duplicate handlers if logger is already configured
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(log_level)
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        
    return logger

agent_logger = setup_logger("SnakeGuardAgent")