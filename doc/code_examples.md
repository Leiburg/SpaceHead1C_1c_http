# Примеры кода

[GET](#get)

[POST](#post)

[Авторизация](#авторизация)

[Использование сессии](#использование-сессии)

[Расширенный список примеров использования](https://github.com/SpaceHead1C/1c_http/wiki/%D0%9F%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D1%8B)

## Методы выполнения HTTP-запросов

Все методы выполнения представлены в модуле `КлиентHTTPКлиентСервер`.

- `Получить` – GET
- `ПолучитьЗаголовки` – HEAD
- `ОтправитьТекст` – POST, тело содержит текст
- `ОтправитьДвоичныеДанные` – POST, тело содержит двоичные данные
- `ОтправитьФайл` – POST, тело содержит двоичные данные переданного по имени файла
- `ОтправитьДанныеФормы` – POST, тело содержит данные формата `multipart/form-data`
- `ОтправитьДанныеHTMLФормы` – POST, тело содержит данные формата `application/x-www-form-urlencoded`
- `ЗаписатьТекст` – PUT, тело содержит текст
- `ЗаписатьДвоичныеДанные` – PUT, тело содержит двоичные данные
- `ЗаписатьФайл` – PUT, тело содержит двоичные данные переданного по имени файла
- `Удалить` – DELETE, допускается тело в виде текста

## Описание объекта HTTP-ответа

Методы выполнения возвращают фиксированную структуру со следующими полями:

- `КодСостояния` – Число – код состояния ответа
- `Заголовки` – Соответствие – заголовки ответа
- `Тело` – ДвоичныеДанные | Строка | Структура | Соответствие | ОбъектXDTO | ЗначениеXDTO | Неопределено – содержимое тела ответа
- `ИмяФайлаТела` – Строка | Неопределено – имя файла с содержимым тела ответа

## GET

```bsl
Ответ = КлиентHTTPКлиентСервер.Получить("https://ya.ru");
```

```bsl
URI = "https://evilinsult.com/generate_insult.php";
ПЗ = КлиентHTTPКлиентСервер.НовыеПараметрыЗапроса();

// Добавим параметры URL: ?lang=ru&type=json
КлиентHTTPКлиентСервер
    .ДобавитьПараметр(ПЗ, "lang", "ru")
    .ДобавитьПараметр(ПЗ, "type", "json");

Ответ = КлиентHTTPКлиентСервер.Получить(URI, ПЗ);
Текст = ПолучитьСтрокуИзДвоичныхДанных(Ответ.Тело);
```

```bsl
// Пример сохранения тела ответа в файл
URI = "https://upload.wikimedia.org/wikipedia/commons/0/0d/Africa_and_Europe_from_a_Million_Miles_Away.png";

ДП = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
Ответ = КлиентHTTPКлиентСервер
    .УстановитьИмяВыходногоФайла(ДП, "С:\tmp\pic.png")
    .Получить(URI, , ДП);
```

[вверх](#примеры-кода)

## POST

```bsl
URI = "https://jsonplaceholder.typicode.com/posts";
Данные = "{""title"": ""foo"", ""body"": ""bar"", ""userId"": 1}";

ДП = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
Ответ = КлиентHTTPКлиентСервер
    .УстановитьТипMIME(ДП, КлиентHTTPПовтИсп.ТипMIMEJSON())
    .УстановитьКодировку(ДП, КлиентHTTPПовтИсп.КодировкаUTF16())
    .ОтправитьТекст(URI, Данные, ДП);
Текст = ПолучитьСтрокуИзДвоичныхДанных(Ответ.Тело);
```

### multipart/form-data

```bsl
URI = "https://httpbin.org/post";

ПФ = КлиентHTTPКлиентСервер.НовыеПоляФормы();
ФайлПоля = Новый Файл("C:\temp\1.png");

Ответ = КлиентHTTPКлиентСервер
    .ДобавитьПолеФормыФайл(ПФ, "my_file", ФайлПоля, ФайлПоля.Имя, КлиентHTTPСлужебный.ТипMIMEРасширенияФайла(ФайлПоля.Расширение))
    .ДобавитьПолеФормыТекст(ПФ, "user_name", "Имярек")
    .ОтправитьДанныеФормы(URI, ПФ);
Текст = ПолучитьСтрокуИзДвоичныхДанных(Ответ.Тело);
```

### application/x-www-form-urlencoded

```bsl
оURI = КлиентHTTPКлиентСервер.ОбъектИдентификатораРесурса("httpbin.org", , "post"); // https://httpbin.org/post
ПФ = КлиентHTTPКлиентСервер.НовыеПоляФормы();
ДП = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();

Ответ = КлиентHTTPКлиентСервер
    .ДобавитьПолеHTMLФормы(ПФ, "user_name", "Имярек")
    .ДобавитьПолеHTMLФормы(ПФ, "role", "Сотрудник")
    .ТелоОтветаКакТекст(ДП)
    .ОтправитьДанныеHTMLФормы(оURI, ПФ, ДП);
```

[вверх](#примеры-кода)

## Авторизация

```bsl
ДП = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
Ответ = КлиентHTTPКлиентСервер
    .УстановитьDigestАвторизацию(ДП, "login", "password")
    .Получить("http://192.168.1.1", , ДП);
```

[вверх](#примеры-кода)

## Использование сессии

включение Cookie и перенаправлений

```bsl
ДП = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();

КлиентHTTPКлиентСервер.ИспользоватьСессию(ДП);

Ответ1 = КлиентHTTPКлиентСервер.Получить("https://www.google.com/search?q=infostart", , ДП);
Ответ2 = КлиентHTTPКлиентСервер.Получить("https://play.google.com/store/search?q=infostart", , ДП);
```

[вверх](#примеры-кода)

---

[Расширенный список примеров использования](https://github.com/SpaceHead1C/1c_http/wiki/%D0%9F%D1%80%D0%B8%D0%BC%D0%B5%D1%80%D1%8B)

[Документация](https://github.com/SpaceHead1C/1c_http/wiki/%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D1%8F)
