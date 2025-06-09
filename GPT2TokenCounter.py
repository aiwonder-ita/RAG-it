#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Modulo per contare i token GPT-2 nei file di testo.
Da usare come libreria in Robot Framework.
"""


from datetime import datetime
from typing import Tuple, List, Dict, Any

# Verifica se transformers è installato e lo importa
try:
    from transformers import GPT2Tokenizer
    TOKENIZER_AVAILABLE = True
except ImportError:
    TOKENIZER_AVAILABLE = False
    print("ATTENZIONE: La libreria 'transformers' non è installata.")
    print("Esegui: pip install transformers")

def check_tokenizer_installed() -> None:
    """Verifica che il tokenizer sia installato e disponibile."""
    if not TOKENIZER_AVAILABLE:
        raise ImportError(
            "La libreria 'transformers' non è installata. "
            "Esegui: pip install transformers"
        )

def count_tokens_in_file(file_path: str) -> int:
    """
    Carica un file, tokenizza il suo contenuto con GPT-2 e conta i token.
    
    Args:
        file_path: Percorso al file da analizzare
        
    Returns:
        int: Numero di token GPT-2 nel file
    """
    check_tokenizer_installed()
    
    # Carica il tokenizer GPT-2
    tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
    
    # Leggi il contenuto del file
    with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    
    # Tokenizza il contenuto
    tokens = tokenizer.encode(content)
    num_tokens = len(tokens)
    
    return num_tokens



def count_tokens_in_txt(text: str) -> int:
    """
    Tokenizza il contenuto di una stringa di testo con GPT-2 e conta i token.
    
    Args:
        text: La stringa di testo da analizzare
        
    Returns:
        int: Numero di token GPT-2 nella stringa
    """
    check_tokenizer_installed()
    
    # Carica il tokenizer GPT-2
    tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
    
    # Tokenizza il contenuto della stringa
    tokens = tokenizer.encode(text)
    num_tokens = len(tokens)
    
    return num_tokens
