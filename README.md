# dictionaryGen

## Description:
По списку слов создаёт таблицу, содержащую перевод, транскрипцию и примеры употребления.

## Usage:
```shell
$ dictionaryGen [list of words]
```
Выходной файл: dictionary.pdf

## Requirements:
* Переменная окружения YANDEX_APIKEY_DICT должна содержать API-ключ [Yandex.Dictionary](https://dictionary.yandex.net).
* Для генерации pdf-файла требуется шрифт **Doulos SIL** и **XeLaTeX**.
