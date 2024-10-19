from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import MarianMTModel, MarianTokenizer
import os
import uuid

app = FastAPI()

# Request model
class TranslationRequest(BaseModel):
    id: uuid.UUID
    message: str
    languageFrom: str
    languageTo: str

# Response model
class TranslationResponse(BaseModel):
    message: str

@app.post("/translate", response_model=TranslationResponse)
async def translate(request: TranslationRequest):
    if not request.message:
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    
    # Mock translation logic
    translated_message = translate(request.message, request.languageFrom, request.languageTo)
    
    return TranslationResponse(message=translated_message)

# Run the application
# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)

# Установка переменных окружения
os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"

def translate(text, src_lang, tgt_lang):
    # Имя модели на Hugging Face
    model_name = f'Helsinki-NLP/opus-mt-{src_lang}-{tgt_lang}'

    # Указание директории для кэширования модели
    cache_dir = os.path.abspath('translation_models')

    # Загрузка токенизатора и модели с указанием папки кэша
    tokenizer = MarianTokenizer.from_pretrained(model_name, cache_dir=cache_dir)
    model = MarianMTModel.from_pretrained(model_name, cache_dir=cache_dir)

    # Перевод текста
    translated = model.generate(**tokenizer(text, return_tensors="pt", padding=True))
    translated_text = [tokenizer.decode(t, skip_special_tokens=True) for t in translated]
    return translated_text[0]

if __name__ == "__main__":
    import sys
    text = sys.argv[1]
    src_lang = sys.argv[2]
    tgt_lang = sys.argv[3]
    try:
        result = translate(text, src_lang, tgt_lang)
        print(result)
    except Exception as e:
        print(f"Error during translation: {e}")

