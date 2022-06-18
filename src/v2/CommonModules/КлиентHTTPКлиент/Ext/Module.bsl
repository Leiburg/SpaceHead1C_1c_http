
// SPDX-License-Identifier: Apache-2.0+

#Область ПрограммныйИнтерфейс
// Реализация POST типа application/x-www-form-urlencoded
//
// Параметры:
//  ИдентификаторРесурса	 - Строка, Структура - URI сервиса либо объект идентификатора ресурса
//  Данные					 - Массив			 - поля HTML-формы. Элементы - Структура с ключами:
//  * Ключ - Строка - имя поля
//  * Значение - Строка - значение поля
//  ДополнительныеПараметры	 - Структура		 - конфигурация выполнения запроса (необязательный)
//  ПараметрыЗапроса		 - Соответствие		 - коллекция параметров запроса (необязательный)
// 
// Возвращаемое значение:
//  Обещание - содержит объект ответа (ФиксированнаяСтруктура):
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Асинх Функция ОтправитьДанныеHTMLФормы(ИдентификаторРесурса, Данные, ДополнительныеПараметры = Неопределено, ПараметрыЗапроса = Неопределено) Экспорт
	Если ДополнительныеПараметры = Неопределено Тогда
		ДополнительныеПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	КонецЕсли;
	
	КлиентHTTPКлиентСервер.УстановитьТипMIME(ДополнительныеПараметры, КлиентHTTPПовтИсп.ТипMIMEXWWWFormUrlEncoded());
	
	Данные = КлиентHTTPВызовСервера.ЗакодированныеПоляФормыHTML(Данные);
	ИндексПоследнегоПоля = Данные.ВГраница();
	Поток = Новый ПотокВПамяти;
	Запись = Новый ЗаписьДанных(Поток, КлиентHTTPКлиентСервер.КодировкаИзДопПараметров(ДополнительныеПараметры), , "");
	
	Для я = 0 По ИндексПоследнегоПоля Цикл
		ПолеФормы = Данные[я];
		ЕстьЗначениеПоля = (ПолеФормы.Значение <> "");
		РазделительВнешний = ?(я = ИндексПоследнегоПоля, "", "&");
		РазделительВнутренний = ?(ЕстьЗначениеПоля, "=", РазделительВнешний);
		
		Ждать Запись.ЗаписатьСтрокуАсинх(ПолеФормы.Ключ, , РазделительВнутренний);
		Если ЕстьЗначениеПоля Тогда
			Ждать Запись.ЗаписатьСтрокуАсинх(ПолеФормы.Значение, , РазделительВнешний);
		КонецЕсли;
	КонецЦикла;
	
	Возврат КлиентHTTPКлиентСервер.ОтправитьДвоичныеДанные(ИдентификаторРесурса, Поток.ЗакрытьИПолучитьДвоичныеДанные(), ДополнительныеПараметры, ПараметрыЗапроса);
КонецФункции

// Возвращает обещание с объектом обработанного HTTP-ответа
//
// Параметры:
//  Ответ					 - HTTPОтвет - ответ HTTP-сервера на HTTP-запрос
//  ДополнительныеПараметры	 - Структура - конфигурация выполнения HTTP-запроса
// 
// Возвращаемое значение:
//  Обещание - содержит объект ответа (ФиксированнаяСтруктура):
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Асинх Функция ОбъектОбработанногоОтвета(Ответ, ДополнительныеПараметры) Экспорт
	фРезультат = КлиентHTTPКлиентСервер.НовыйОбъектОбработанногоОтвета();
	фРезультат.КодСостояния = Ответ.КодСостояния;
	фРезультат.Заголовки = Ответ.Заголовки;
	фРезультат.Тело = Ждать ТелоОтвета(Ответ, ДополнительныеПараметры);
	фРезультат.ИмяФайлаТела = Ответ.ПолучитьИмяФайлаТела();
	
	Возврат Новый ФиксированнаяСтруктура(фРезультат);
КонецФункции
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Асинх Функция ТелоОтвета(Ответ, ДополнительныеПараметры)
	ДанныеТелаОтвета = ?(
		КлиентHTTPКлиентСервер.ЗначениеЗаголовка(КлиентHTTPПовтИсп.ЗаголовокОтветаСжатиеТела(), Ответ.Заголовки) = Неопределено,
		Ответ.ПолучитьТелоКакДвоичныеДанные(),
		Ждать Декомпрессия(Ответ.ПолучитьТелоКакПоток())
	);
	
	Возврат ?(
		ДополнительныеПараметры.Свойство("ПрочитатьТелоОтветаКак"),
		КлиентHTTPКлиентСервер.ПреобразованноеТелоОтвета(Ответ, ДанныеТелаОтвета, ДополнительныеПараметры.ПрочитатьТелоОтветаКак),
		ДанныеТелаОтвета
	);
КонецФункции

Асинх Функция Декомпрессия(ПотокСжатыхДанных)
	ИмяФайлаВАрхиве = ПолучитьБуферДвоичныхДанныхИзСтроки(Сред(Новый УникальныйИдентификатор, 25), КодировкаТекста.ANSI, Ложь);
	РазмерАрхива = Ждать ПотокСжатыхДанных.РазмерАсинх();
	РазмерСжатыхДанных = РазмерАрхива - 18; // размер префикса + размер постфикса GZip = 18
	
	// Восстановление структуры ZIP-архива
	
	ОбластиZIP = КлиентHTTPПовтИсп.ОбластиФайлаВАрхивеZIP();
	Поток = Новый ПотокВПамяти(ОбластиZIP.РазмерLFH + РазмерСжатыхДанных + ОбластиZIP.РазмерDD + ОбластиZIP.РазмерCDFH + ОбластиZIP.РазмерEOCD);
	
	ОбластиZIP.ОбластьLFH.Записать(30, ИмяФайлаВАрхиве);
	
	Чтение = Новый ЧтениеДанных(ПотокСжатыхДанных);
	Ждать Чтение.ПропуститьАсинх(10); // размер префикса GZip
	
	Запись = Новый ЗаписьДанных(Поток);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьLFH);
	Ждать Чтение.КопироватьВАсинх(Запись, РазмерСжатыхДанных);
	Ждать Запись.ЗакрытьАсинх();
	
	КонтрольнаяСумма = Ждать Чтение.ПрочитатьЦелое32Асинх();
	РазмерНесжатыхДанных = Ждать Чтение.ПрочитатьЦелое32Асинх();
	
	Ждать Чтение.ЗакрытьАсинх();
	
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(4, КонтрольнаяСумма);
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(8, РазмерСжатыхДанных);
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(12, РазмерНесжатыхДанных);

	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(16, КонтрольнаяСумма);
	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(20, РазмерСжатыхДанных);
	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(24, РазмерНесжатыхДанных);
	ОбластиZIP.ОбластьCDFH.Записать(46, ИмяФайлаВАрхиве);

	ОбластиZIP.ОбластьEOCD.ЗаписатьЦелое32(16, ОбластиZIP.РазмерLFH + РазмерСжатыхДанных + ОбластиZIP.РазмерDD);
	
	Запись = Новый ЗаписьДанных(Поток);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьDD);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьCDFH);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьEOCD);
	Ждать Запись.ЗакрытьАсинх();
	
	// Извлечение содержимого ZIP-архива
	
	Каталог = ПолучитьИмяВременногоФайла();
	Чтение = Новый ЧтениеZipФайла(Поток);
	ИмяФайла = Чтение.Элементы[0].Имя;
	Чтение.Извлечь(Чтение.Элементы[0], Каталог, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	Чтение.Закрыть();
	
	фРезультат = Новый ДвоичныеДанные(Каталог + ПолучитьРазделительПутиКлиента() + ИмяФайла);
	Попытка
		Ждать УдалитьФайлыАсинх(Каталог);
	Исключение
		КлиентHTTPВызовСервера.ДобавитьЗаписьОшибкиВЖурналРегистрации(Каталог, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат фРезультат;
КонецФункции
#КонецОбласти
