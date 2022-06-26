﻿
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
//  ФиксированнаяСтруктура - объект ответа:
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Функция ОтправитьДанныеHTMLФормы(Знач ИдентификаторРесурса, Знач Данные, ДополнительныеПараметры = Неопределено, Знач ПараметрыЗапроса = Неопределено) Экспорт
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
		
		Запись.ЗаписатьСтроку(ПолеФормы.Ключ, , РазделительВнутренний);
		Если ЕстьЗначениеПоля Тогда
			Запись.ЗаписатьСтроку(ПолеФормы.Значение, , РазделительВнешний);
		КонецЕсли;
	КонецЦикла;
	
	Возврат КлиентHTTPКлиентСервер.ОтправитьДвоичныеДанные(ИдентификаторРесурса, Поток.ЗакрытьИПолучитьДвоичныеДанные(), ДополнительныеПараметры, ПараметрыЗапроса);
КонецФункции

// Реализация POST типа multipart/form-data. При отсутствии файла генерируется исключение
//
// Параметры:
//  ИдентификаторРесурса	 - Строка, Структура - URI сервиса либо объект идентификатора ресурса
//  Данные					 - Массив			 - тело запроса. Элементы - Структура с ключами:
//  * Ключ - Строка - имя поля
//  * Значение - Строка, Файл - значение поля
//  * ТипMIME - Строка - тип значения поля (необязательный)
//  * Файл - Структура (необязательный), ключи:
//    ** Имя		 - Строка - имя файла (необязательный),
//    ** ТипMIME	 - Строка - MIME-тип содержимого файла (необязательный),
//    ** Кодировка	 - Строка - кодировка файла (необязательный)
//  ДополнительныеПараметры	 - Структура    - конфигурация выполнения запроса (необязательный)
//  ПараметрыЗапроса		 - Соответствие - коллекция параметров запроса (необязательный)
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура - объект ответа:
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Функция ОтправитьДанныеФормы(Знач ИдентификаторРесурса, Знач Данные, ДополнительныеПараметры = Неопределено, Знач ПараметрыЗапроса = Неопределено) Экспорт
	Если ДополнительныеПараметры = Неопределено Тогда
		ДополнительныеПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	КонецЕсли;
	
	Разделитель = ?(ДополнительныеПараметры.Свойство("Разделитель"), ДополнительныеПараметры.Разделитель, XMLСтрока(Новый УникальныйИдентификатор));
	_Разделитель = "--" + Разделитель;
	_Разделитель_ = _Разделитель + "--";
	
	КлиентHTTPКлиентСервер.УстановитьТипMIME(ДополнительныеПараметры, КлиентHTTPПовтИсп.ТипMIMEMultipartFromData());
	
	Поток = Новый ПотокВПамяти;
	Запись = Новый ЗаписьДанных(Поток, КлиентHTTPКлиентСервер.КодировкаИзДопПараметров(ДополнительныеПараметры));
	
	Для Каждого ПолеФормы Из Данные Цикл
		Запись.ЗаписатьСтроку("");
		Запись.ЗаписатьСтроку(_Разделитель);
		
		Если ПолеФормы.Свойство("Файл") Тогда
			ДобавитьДанныеФормыФайл(ПолеФормы, Запись);
		Иначе
			ДобавитьДанныеФормыТекст(ПолеФормы, Запись);
		КонецЕсли;
		
		Запись.ЗаписатьСтроку(_Разделитель_);
	КонецЦикла;
	
	Возврат КлиентHTTPКлиентСервер.ОтправитьДвоичныеДанные(ИдентификаторРесурса, Поток.ЗакрытьИПолучитьДвоичныеДанные(), ДополнительныеПараметры, ПараметрыЗапроса);
КонецФункции

// Парсит значение заголовка ответа Set-Cookie и сохраняет результат в базу Cookie сессии
//
// Параметры:
//  Сессия			 - Структура - данные HTTP-сессии
//  ОписаниеПеченья	 - Строка	 - значение заголовка ответа Set-Cookie
//  СерверURI		 - Строка	 - адрес сервера из разобранного URI
//
Процедура ПринятьПеченье(Сессия, Знач ОписаниеПеченья, Знач СерверURI) Экспорт
	Перем Печенье;
	
	Сессия.Свойство("Печенье", Печенье);
	Если Печенье = Неопределено Тогда
		Печенье = Новый Соответствие;
		Сессия.Вставить("Печенье", Печенье);
	КонецЕсли;
	
	Для Каждого Печенько Из ВыпеченныеПеченьки(ОписаниеПеченья) Цикл
		Получатель = Неопределено;
		
		Для Каждого Атрибут Из Печенько.Атрибуты Цикл
			Если Атрибут.Имя = "domain" Тогда
				Получатель = СокрЛП(Атрибут.Значение);
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Получатель = КлиентHTTPСлужебный.НормализованныйАдресСервера(
			?(ЗначениеЗаполнено(Получатель), Получатель, СерверURI)
		);
		
		ПеченьеПолучателя = Печенье.Получить(Получатель);
		Если ПеченьеПолучателя = Неопределено Тогда
			ПеченьеПолучателя = Новый Соответствие;
			Печенье.Вставить(Получатель, ПеченьеПолучателя);
		КонецЕсли;
		
		ПеченьеПолучателя.Вставить(
			НРег(СокрЛП(Печенько.Имя)),
			СвойстваПеченьки(Печенько.Имя, Печенько.Значение, Печенько.Атрибуты)
		);
	КонецЦикла;
КонецПроцедуры

// Возвращает текущую универсальную дату сервера
// 
// Возвращаемое значение:
//  Дата - текущая универсальная дата сервера
//
Функция ТекущаяУниверсальнаяДатаНаСервере() Экспорт
	Возврат ТекущаяУниверсальнаяДата();
КонецФункции

// Возвращает раскодированный URI в URL кодировке
//
// Параметры:
//  ИдентификаторРесурса - Строка	 - URI
// 
// Возвращаемое значение:
//  Строка - раскодированная строка идентификатора ресурса
//
Функция РаскодированныйИдентификаторРесурса(Знач ИдентификаторРесурса) Экспорт
	Возврат РаскодироватьСтроку(ИдентификаторРесурса, СпособКодированияСтроки.URLВКодировкеURL);
КонецФункции

// Возвращает значение заголовка Digest-аутентификации
//
// Параметры:
//  Конфигурация				 - Структура - конфигурация выполнения запроса
//  КонтекстВыполненияАдресВХ	 - Строка	 - адрес контекста выполнения запроса во временном хранилище
// 
// Возвращаемое значение:
//  Строка - значение заголовка Digest-авторизации
//
Функция ЗаголовокDigest(Знач Конфигурация, Знач КонтекстВыполненияАдресВХ) Экспорт
	КонтекстВыполнения = ПолучитьИзВременногоХранилища(КонтекстВыполненияАдресВХ);
	УдалитьИзВременногоХранилища(КонтекстВыполненияАдресВХ);
	
	Параметры = Конфигурация.ДополнительныеПараметры.Сессия.ПараметрыDigest;
	Аутентификация = Конфигурация.ДополнительныеПараметры.Аутентификация;
	АдресРесурсаСПараметрами = Конфигурация.ДанныеURI.АдресРесурса + Конфигурация.Параметры;
	АлгоритмХеширования = НРег(Параметры.algorithm);
	УникальныйКлючКлиента = Лев(СтрЗаменить(НРег(Новый УникальныйИдентификатор), "-", ""), 16);
	
	КачествоЗащиты = Неопределено;
	Если ЗначениеЗаполнено(Параметры.qop) Тогда
		КачествоЗащиты = ?(СтрРазделить(НРег(Параметры.qop), ",", Ложь).Найти("auth") = Неопределено, "auth-int", "auth");
	КонецЕсли;
	
	A1 = СтрШаблон("%1:%2:%3", Аутентификация.Пользователь, Параметры.realm, Аутентификация.Пароль);
	HA1 = ХешСтрока(A1, АлгоритмХеширования);
	Если СтрЗаканчиваетсяНа(АлгоритмХеширования, "-sess") Тогда
		HA1 = ХешСтрока(СтрШаблон("%1:%2:%3", HA1, Параметры.nonce, УникальныйКлючКлиента), АлгоритмХеширования);
	КонецЕсли;
	
	A2 = ?(
	    КачествоЗащиты = "auth-int",
		СтрШаблон("%1:%2:%3", КонтекстВыполнения.Метод, АдресРесурсаСПараметрами, ХешСтрока(КонтекстВыполнения.Данные, АлгоритмХеширования)),
		СтрШаблон("%1:%2", КонтекстВыполнения.Метод, АдресРесурсаСПараметрами)
	);
	HA2 = ХешСтрока(A2, АлгоритмХеширования);
	
	Если НЕ Параметры.Свойство("lastnonce") Тогда
		Параметры.Вставить("lastnonce");
	КонецЕсли;
	
	Если Параметры.nonce = Параметры.lastnonce Тогда
		Параметры.nonce_count = Параметры.nonce_count + 1;
	Иначе
		Параметры.Вставить("nonce_count", 1);
	КонецЕсли;
	
	КоличествоИспользованийNonce = Формат(Параметры.nonce_count, "ЧЦ=8; ЧВН=; ЧГ=");
	
	Ответ = ХешСтрока(
		?(
			КачествоЗащиты = Неопределено,
			СтрШаблон("%1:%2:%3", HA1, Параметры.nonce, HA2),
			СтрШаблон("%1:%2:%3:%4:%5:%6", HA1, Параметры.nonce, КоличествоИспользованийNonce, УникальныйКлючКлиента, КачествоЗащиты, HA2)
		),
		АлгоритмХеширования
	);
	
	Параметры.lastnonce = Параметры.nonce;
	
	фРезультат = Новый Массив;
	фРезультат.Добавить("Digest ");
	фРезультат.Добавить(
		СтрШаблон(
			"username=""%1"", realm=""%2"", nonce=""%3"", uri=""%4"", response=""%5""",
			Конфигурация.ДополнительныеПараметры.Аутентификация.Пользователь,
			Параметры.realm,
			Параметры.nonce,
			АдресРесурсаСПараметрами,
			Ответ
		)
	);

	Если ЗначениеЗаполнено(Параметры.opaque) Тогда
		фРезультат.Добавить(СтрШаблон(", opaque=""%1""", Параметры.opaque));
	КонецЕсли;
	Если ЗначениеЗаполнено(Параметры.algorithm) Тогда
		фРезультат.Добавить(СтрШаблон(", algorithm=""%1""", Параметры.algorithm));
	КонецЕсли;
	Если ЗначениеЗаполнено(Параметры.qop) Тогда
		фРезультат.Добавить(СтрШаблон(", qop=""auth"", nc=%1, cnonce=""%2""", КоличествоИспользованийNonce, УникальныйКлючКлиента));
	КонецЕсли;

	Возврат СтрСоединить(фРезультат);
КонецФункции

// Возвращает объект обработанного HTTP-ответа
//
// Параметры:
//  Ответ					 - HTTPОтвет - ответ HTTP-сервера на HTTP-запрос
//  ДополнительныеПараметры	 - Структура - конфигурация выполнения HTTP-запроса
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура - объект ответа:
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Функция ОбъектОбработанногоОтвета(Ответ, ДополнительныеПараметры) Экспорт
	фРезультат = КлиентHTTPКлиентСервер.НовыйОбъектОбработанногоОтвета();
	фРезультат.КодСостояния = Ответ.КодСостояния;
	фРезультат.Заголовки = Ответ.Заголовки;
	фРезультат.Тело = ТелоОтвета(Ответ, ДополнительныеПараметры);
	фРезультат.ИмяФайлаТела = Ответ.ПолучитьИмяФайлаТела();
	
	Возврат Новый ФиксированнаяСтруктура(фРезультат);
КонецФункции

// Возвращает коллекцию раскодированных строк
//
// Параметры:
//  КоллекцияСтрок	 - Структура	 - коллекция строк для раскодирования (обрабатываются только значения)
//  Способ			 - СпособКодированияСтроки	 - способ, которым была закодирована исходная строка
// 
// Возвращаемое значение:
//  Структура - коллекция раскодированных строк
//
Функция РаскодированныеСтроки(Знач КоллекцияСтрок, Знач Способ = Неопределено) Экспорт
	фРезультат = Новый Структура;
	
	Если Способ = Неопределено Тогда
		Способ = СпособКодированияСтроки.URLВКодировкеURL;
	КонецЕсли;
	
	Для Каждого КЗ Из КоллекцияСтрок Цикл
		фРезультат.Вставить(КЗ.Ключ, РаскодироватьСтроку(КЗ.Значение, Способ));
	КонецЦикла;
	
	Возврат фРезультат;
КонецФункции

// Возвращает коллекцию кодированных строк
//
// Параметры:
//  КоллекцияСтрок	 - Структура	 - коллекция строк для кодирования (обрабатываются только значения)
//  Способ			 - СпособКодированияСтроки	 - способ кодирования строки
// 
// Возвращаемое значение:
//  Структура - коллекция кодированных строк
//
Функция ЗакодированныеСтроки(Знач КоллекцияСтрок, Знач Способ = Неопределено) Экспорт
	фРезультат = Новый Структура;
	
	Если Способ = Неопределено Тогда
		Способ = СпособКодированияСтроки.URLВКодировкеURL;
	КонецЕсли;
	
	Для Каждого КЗ Из КоллекцияСтрок Цикл
		фРезультат.Вставить(КЗ.Ключ, КодироватьСтроку(КЗ.Значение, Способ));
	КонецЦикла;
	
	Возврат фРезультат;
КонецФункции

// Возвращает коллекцию раскодированных полей HTML-Формы
//
// Параметры:
//  ПоляФормыHTML	 - Массив	 - поля HTML-формы
// 
// Возвращаемое значение:
//  Массив - коллекция раскодированных полей HTML-формы
//
Функция РаскодированныеПоляФормыHTML(Знач ПоляФормыHTML) Экспорт
	фРезультат = КлиентHTTPКлиентСервер.НовыеПоляФормы();
	Способ = СпособКодированияСтроки.КодировкаURL;
	
	Для Каждого Поле Из ПоляФормыHTML Цикл
		КлиентHTTPКлиентСервер.ДобавитьПолеHTMLФормы(фРезультат, РаскодироватьСтроку(Поле.Ключ, Способ), РаскодироватьСтроку(Поле.Значение, Способ));
	КонецЦикла;
	
	Возврат фРезультат;
КонецФункции

// Возвращает коллекцию закодированных полей HTML-Формы
//
// Параметры:
//  ПоляФормыHTML	 - Массив	 - поля HTML-формы
// 
// Возвращаемое значение:
//  Массив - коллекция закодированных полей HTML-формы
//
Функция ЗакодированныеПоляФормыHTML(Знач ПоляФормыHTML) Экспорт
	фРезультат = КлиентHTTPКлиентСервер.НовыеПоляФормы();
	Способ = СпособКодированияСтроки.КодировкаURL;
	
	Для Каждого Поле Из ПоляФормыHTML Цикл
		КлиентHTTPКлиентСервер.ДобавитьПолеHTMLФормы(фРезультат, КодироватьСтроку(Поле.Ключ, Способ), КодироватьСтроку(Поле.Значение, Способ));
	КонецЦикла;
	
	Возврат фРезультат;
КонецФункции
#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс
// Добавляет запись ошибки в журнал регистрации
//
// Параметры:
//     Данные - Ссылка, Число, Строка, Дата, Булево, Неопределено, Null, Тип - данные, с которыми связано событие
//     Комментарий - Строка - произвольная строка комментария к событию
//     СобытиеВТранзакции - Булево - аргумент возвращаемого значения, открыта ли транзакция на момент добавления записи в журнал регистрации
//
Процедура ДобавитьЗаписьОшибкиВЖурналРегистрации(Знач Данные = Неопределено, Знач Комментарий = "", СобытиеВТранзакции = Ложь) Экспорт
#Если НЕ МобильноеПриложениеСервер Тогда
	СобытиеВТранзакции = ТранзакцияАктивна();
	
	ЗаписьЖурналаРегистрации(
		КлиентHTTPПовтИсп.ИмяСобытия(),
		УровеньЖурналаРегистрации.Ошибка,
		,
		Данные,
		Комментарий,
		?(СобытиеВТранзакции, РежимТранзакцииЗаписиЖурналаРегистрации.Транзакционная, РежимТранзакцииЗаписиЖурналаРегистрации.Независимая)
	);
#КонецЕсли
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Функция ВыпеченныеПеченьки(Знач ОписаниеПеченья)
	фРезультат = Новый Массив;
	НормализованноеОписаниеПеченья = НРег(ОписаниеПеченья);
	ДлинаОписания = СтрДлина(НормализованноеОписаниеПеченья);
	СостоянияДКА = КлиентHTTPПовтИсп.СостоянияДКАПарсингаПеченья();
	ДКА = КлиентHTTPПовтИсп.ДКАПарсингаПеченья();
	
	Действие = НовоеДействие(Истина, Ложь, Ложь, Ложь, Ложь, Ложь);
	ОписанияПеченья = Новый Структура("Исходное, Нормализованное, Длина", ОписаниеПеченья, НормализованноеОписаниеПеченья, ДлинаОписания);
	СостояниеЧтения = Новый Структура("Позиция, Токен, ПрочитаноЗапятых, КоличествоЗапятых", 1, Неопределено, 0, Неопределено);
	СостояниеПеченьки = Новый Структура("Объект, Построитель", НоваяПеченька(), Новый Массив);
	СостояниеАтрибута = Новый Структура("Объект, Построитель", НовыйАтрибутПеченьки(), Новый Массив);
	СостояниеДКА = Новый Структура("Текущее, Очередное", СостоянияДКА.ИмяПеченьки, "");

	Для Каждого ПозицияТокена Из ПозицииТокеновПеченья(НормализованноеОписаниеПеченья) Цикл
		Если ПозицияТокена.Позиция = 1 Тогда // иногда имена Cookie совпадают с именами атрибутов
			Продолжить;
		КонецЕсли;
		
		СледующаяПозиция = Ложь;
		СостояниеЧтения.Токен = ПозицияТокена;
		
		ОбработатьПереходноеСостояниеДКА(фРезультат, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута, СледующаяПозиция);
		Если СледующаяПозиция Тогда
			Продолжить;
		КонецЕсли;
		
		СостояниеДКА.Очередное = ДКА.Получить(СостояниеДКА.Текущее).Получить(СостояниеЧтения.Токен.ТипТокена);
		ОбработатьОчередноеСостояниеДКА(фРезультат, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута);
	КонецЦикла;

	ОбработатьФинальноеСостоянияДКА(фРезультат, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута);
	
	Возврат фРезультат;
КонецФункции

Функция НоваяПеченька()
	Возврат Новый Структура("Имя, Значение, Атрибуты", "", "", Новый Массив);
КонецФункции

Функция НовыйАтрибутПеченьки(Знач Имя = Неопределено, Знач Значение = Неопределено)
	Возврат Новый Структура("Имя, Значение", Имя, Значение);
КонецФункции

Функция НовоеДействие(ЗаписатьИмяПеченьки, ЗаписатьЗначениеПеченьки, СобиратьЗначениеПеченьки, ПроверитьИмяАтрибута, ЗаписатьАтрибут, СобиратьЗначениеАтрибута)
	Возврат Новый Структура(
		"ЗаписатьИмяПеченьки, ЗаписатьЗначениеПеченьки, СобиратьЗначениеПеченьки, ПроверитьИмяАтрибута, ЗаписатьАтрибут, СобиратьЗначениеАтрибута",
		ЗаписатьИмяПеченьки,
		ЗаписатьЗначениеПеченьки,
		СобиратьЗначениеПеченьки,
		ПроверитьИмяАтрибута,
		ЗаписатьАтрибут,
		СобиратьЗначениеАтрибута
	);
КонецФункции

Процедура ОбработатьСостояниеДКАИмяПеченьки(Печеньки, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута)
	Если Действие.ЗаписатьАтрибут Тогда
		Действие.ЗаписатьАтрибут = Ложь;
		
		Если Действие.СобиратьЗначениеАтрибута Тогда
			Действие.СобиратьЗначениеАтрибута = Ложь;
			СостояниеАтрибута.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Нормализованное, СостояниеЧтения));
			СостояниеАтрибута.Объект.Значение = СтрСоединить(СостояниеАтрибута.Построитель);
		КонецЕсли;
		
		СостояниеПеченьки.Объект.Атрибуты.Добавить(СостояниеАтрибута.Объект);
	КонецЕсли;
	Печеньки.Добавить(СостояниеПеченьки.Объект);
	СостояниеПеченьки.Объект = НоваяПеченька();
	Действие.ЗаписатьИмяПеченьки = Истина;
	ПереключитьСостояниеДКА(СостояниеДКА);
	СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
КонецПроцедуры

Процедура ОбработатьСостояниеДКАЗначениеПеченьки(СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки)
	Если Действие.ЗаписатьЗначениеПеченьки Тогда
		СостояниеПеченьки.Объект.Значение = СостояниеПеченьки.Объект.Значение + ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения);
		СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция;
	Иначе
		СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
	КонецЕсли;
	Действие.ЗаписатьЗначениеПеченьки = Истина;
	СостояниеПеченьки.Построитель = Новый Массив;
	ПереключитьСостояниеДКА(СостояниеДКА);
КонецПроцедуры

Процедура ОбработатьСостояниеДКАИмяАтрибута(Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута)
	Если Действие.ЗаписатьЗначениеПеченьки Тогда
		Действие.ЗаписатьЗначениеПеченьки = Ложь;
		СостояниеПеченьки.Объект.Значение = СостояниеПеченьки.Объект.Значение + ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения);
	ИначеЕсли Действие.ЗаписатьАтрибут Тогда
		Действие.ЗаписатьАтрибут = Ложь;
		Действие.СобиратьЗначениеАтрибута = Ложь;
		СостояниеАтрибута.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Нормализованное, СостояниеЧтения));
		СостояниеАтрибута.Объект.Значение = СтрСоединить(СостояниеАтрибута.Построитель);
		СостояниеПеченьки.Объект.Атрибуты.Добавить(СостояниеАтрибута.Объект);
		СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
	КонецЕсли;
	
	// на следующем шаге проверить имя атрибута и начать его писать
	Действие.ПроверитьИмяАтрибута = Истина;
КонецПроцедуры

Процедура ОбработатьСостояниеДКАЗначениеАтрибута(СостояниеДКА, СостояниеЧтения)
	// начать собирать значение атрибута
	СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
	ПереключитьСостояниеДКА(СостояниеДКА);
КонецПроцедуры

Процедура ОбработатьСостояниеДКАИмяИлиЗначениеПеченьки(СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки)
	// собирать значение печеньки пока не придёт знак (ТипТокена В {1, 2}) его записать
	Действие.ЗаписатьЗначениеПеченьки = Ложь;
	Действие.СобиратьЗначениеПеченьки = Истина;
	СостояниеПеченьки.Построитель.Добавить(СостояниеПеченьки.Объект.Значение + ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения));
	СостояниеПеченьки.Построитель.Добавить(СостояниеЧтения.Токен.Токен);
	СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
	ПереключитьСостояниеДКА(СостояниеДКА);
КонецПроцедуры

Процедура ОбработатьСостояниеДКАИмяПеченькиИлиЗначениеАтрибута(СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеАтрибута)
	// собирать значение атрибута пока не придёт знак (ТипТокена В {1, 2}) его записать
	Действие.ЗаписатьАтрибут = Ложь;
	Действие.СобиратьЗначениеАтрибута = Истина;
	СостояниеАтрибута.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Нормализованное, СостояниеЧтения));
	СостояниеАтрибута.Построитель.Добавить(СостояниеЧтения.Токен.Токен);
	СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
	ПереключитьСостояниеДКА(СостояниеДКА);
КонецПроцедуры

Процедура ОбработатьДействиеСобиратьЗначениеПеченьки(Печеньки, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки)
	ТипыТокенов = КлиентHTTPПовтИсп.ТипыТокеновПарсингаПеченья();
	
	Если СостояниеЧтения.Токен.ТипТокена = ТипыТокенов.РазделителиПар Тогда // это уже следующая печенька
		СостояниеПеченьки.Построитель.Удалить(СостояниеПеченьки.Построитель.ВГраница());
	ИначеЕсли СостояниеЧтения.Токен.ТипТокена = ТипыТокенов.РазделителиПеченья Тогда // добавить фрагмент значения печеньки
		СостояниеПеченьки.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения));
		СостояниеПеченьки.Построитель.Добавить(СостояниеЧтения.Токен.Токен);
		СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
		СледующаяПозиция = Истина;
		Возврат;
	Иначе // ТипТокена = ТипыТокенов.РазделителиАтрибутов
		СостояниеПеченьки.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения));
	КонецЕсли;
	
	СостояниеПеченьки.Объект.Значение = СтрСоединить(СостояниеПеченьки.Построитель);
	Действие.СобиратьЗначениеПеченьки = Ложь;
	
	Если СостояниеЧтения.Токен.ТипТокена = ТипыТокенов.РазделителиПар Тогда // это уже следующая печенька
		Печеньки.Добавить(СостояниеПеченьки.Объект);
		СостояниеПеченьки.Объект = НоваяПеченька();
		Действие.ЗаписатьИмяПеченьки = Истина;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработатьДействиеСобиратьЗначениеАтрибута(Печеньки, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута)
	ТипыТокенов = КлиентHTTPПовтИсп.ТипыТокеновПарсингаПеченья();
	
	Если СостояниеЧтения.Токен.ТипТокена = ТипыТокенов.РазделителиПар Тогда // это уже следующая печенька
		СостояниеАтрибута.Построитель.Удалить(СостояниеАтрибута.Построитель.ВГраница());
	ИначеЕсли СостояниеЧтения.Токен.ТипТокена = ТипыТокенов.РазделителиПеченья Тогда  // добавить фрагмент значения атрибута
		// Анализировать по формату конкретного атрибута
		СостояниеАтрибута.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Нормализованное, СостояниеЧтения));
		СостояниеАтрибута.Построитель.Добавить(СостояниеЧтения.Токен.Токен);
		СостояниеЧтения.ПрочитаноЗапятых = СостояниеЧтения.ПрочитаноЗапятых + 1;
		Если СостояниеЧтения.КоличествоЗапятых <> Неопределено
			 И СостояниеЧтения.ПрочитаноЗапятых >= СостояниеЧтения.КоличествоЗапятых Тогда
			Действие.СобиратьЗначениеАтрибута = Ложь;
			СостояниеАтрибута.Построитель.Удалить(СостояниеАтрибута.Построитель.ВГраница());
			ПереключитьСостояниеДКА(СостояниеДКА);
		Иначе
			СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + 1;
			СледующаяПозиция = Истина;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	СостояниеАтрибута.Объект.Значение = СтрСоединить(СостояниеАтрибута.Построитель);
	Действие.ЗаписатьАтрибут = Истина;
	
	Если СостояниеЧтения.Токен.ТипТокена = ТипыТокенов.РазделителиПар Тогда // это уже следующая печенька
		Действие.ЗаписатьАтрибут = Ложь;
		Действие.СобиратьЗначениеАтрибута = Ложь;
		СостояниеПеченьки.Объект.Атрибуты.Добавить(СостояниеАтрибута.Объект);
		Печеньки.Добавить(СостояниеПеченьки.Объект);
		СостояниеПеченьки.Объект = НоваяПеченька();
		Действие.ЗаписатьИмяПеченьки = Истина;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработатьДействиеЗаписатьИмяПеченьки(Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки)
	СостояниеПеченьки.Объект.Имя = СокрЛП(ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения));
	Действие.ЗаписатьИмяПеченьки = Ложь;
КонецПроцедуры

Процедура ОбработатьДействиеПроверитьИмяАтрибута(СостояниеДКА, Действие, СостояниеЧтения, СостояниеАтрибута)
	ТипыТокенов = КлиентHTTPПовтИсп.ТипыТокеновПарсингаПеченья();
	Если СостояниеЧтения.Токен.ТипТокена <> ТипыТокенов.Атрибуты Тогда
		// Не реализована обработка отсутствующего атрибута 
		ВызватьИсключение "Неизвестное имя атрибута Cookie: " + СостояниеЧтения.Токен.Токен;
	КонецЕсли;
	
	СостояниеАтрибута.Объект = НовыйАтрибутПеченьки(СостояниеЧтения.Токен.Токен);
	СостояниеАтрибута.Построитель = Новый Массив;
	СостояниеЧтения.Позиция = СостояниеЧтения.Токен.Позиция + СостояниеЧтения.Токен.Смещение;
	Действие.ПроверитьИмяАтрибута = Ложь;
	Действие.ЗаписатьАтрибут = Истина;
	СостояниеЧтения.ПрочитаноЗапятых = 0;
	СостояниеЧтения.КоличествоЗапятых = СостояниеЧтения.Токен.КоличествоЗапятых;
	ПереключитьСостояниеДКА(СостояниеДКА);
КонецПроцедуры

Процедура ОбработатьПереходноеСостояниеДКА(Печеньки, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута, СледующаяПозиция)
	// Логика состояния ИмяИлиЗначениеПеченьки (AB)
	Если Действие.СобиратьЗначениеПеченьки Тогда
		ОбработатьДействиеСобиратьЗначениеПеченьки(Печеньки, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки);
	// Логика состояния ИмяПеченькиИлиЗначениеАтрибута (AD)
	ИначеЕсли Действие.СобиратьЗначениеАтрибута Тогда
		ОбработатьДействиеСобиратьЗначениеАтрибута(Печеньки, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута);
	КонецЕсли;
	
	Если Действие.ЗаписатьИмяПеченьки Тогда
		ОбработатьДействиеЗаписатьИмяПеченьки(Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки);
	ИначеЕсли Действие.ПроверитьИмяАтрибута Тогда
		ОбработатьДействиеПроверитьИмяАтрибута(СостояниеДКА, Действие, СостояниеЧтения, СостояниеАтрибута);
		СледующаяПозиция = Истина;
	КонецЕсли;
КонецПроцедуры

Процедура ОбработатьОчередноеСостояниеДКА(Печеньки, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута)
	СостоянияДКА = КлиентHTTPПовтИсп.СостоянияДКАПарсингаПеченья();
	Если СостояниеДКА.Очередное = СостоянияДКА.ИмяПеченьки Тогда
		ОбработатьСостояниеДКАИмяПеченьки(Печеньки, СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута);
	ИначеЕсли СостояниеДКА.Очередное = СостоянияДКА.ЗначениеПеченьки Тогда
		ОбработатьСостояниеДКАЗначениеПеченьки(СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки);
	ИначеЕсли СостояниеДКА.Очередное = СостоянияДКА.ИмяАтрибута Тогда
		ОбработатьСостояниеДКАИмяАтрибута(Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута);
	ИначеЕсли СостояниеДКА.Очередное = СостоянияДКА.ЗначениеАтрибута Тогда
		ОбработатьСостояниеДКАЗначениеАтрибута(СостояниеДКА, СостояниеЧтения);
	ИначеЕсли СостояниеДКА.Очередное = СостоянияДКА.ИмяИлиЗначениеПеченьки Тогда
		ОбработатьСостояниеДКАИмяИлиЗначениеПеченьки(СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеПеченьки);
	ИначеЕсли СостояниеДКА.Очередное = СостоянияДКА.ИмяПеченькиИлиЗначениеАтрибута Тогда
		ОбработатьСостояниеДКАИмяПеченькиИлиЗначениеАтрибута(СостояниеДКА, Действие, СостояниеЧтения, ОписанияПеченья, СостояниеАтрибута);
	Иначе	
		ВызватьИсключение "Не удалось разобрать заголовок Set-Cookie";
	КонецЕсли;
КонецПроцедуры

Процедура ПереключитьСостояниеДКА(Состояние)
	Состояние.Текущее = Состояние.Очередное;
КонецПроцедуры

Процедура ОбработатьФинальноеСостоянияДКА(Печеньки, ФинальноеДействие, СостояниеЧтения, Знач ОписанияПеченья, СостояниеПеченьки, СостояниеАтрибута)
	Если ФинальноеДействие.ЗаписатьЗначениеПеченьки Тогда
		СостояниеПеченьки.Объект.Значение = ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения);
		Печеньки.Добавить(СостояниеПеченьки.Объект);
	ИначеЕсли ФинальноеДействие.СобиратьЗначениеПеченьки Тогда
		СостояниеПеченьки.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения));
		СостояниеПеченьки.Объект.Значение = СтрСоединить(СостояниеПеченьки.Построитель);
		Печеньки.Добавить(СостояниеПеченьки.Объект);
	ИначеЕсли ФинальноеДействие.ЗаписатьАтрибут Тогда
		СостояниеАтрибута.Объект.Значение = ЧастьОписанияПеченья(ОписанияПеченья.Нормализованное, СостояниеЧтения);
		СостояниеПеченьки.Объект.Атрибуты.Добавить(СостояниеАтрибута.Объект);
		Печеньки.Добавить(СостояниеПеченьки.Объект);
	ИначеЕсли ФинальноеДействие.СобиратьЗначениеАтрибута Тогда
		ФинальноеДействие.ЗаписатьИмяПеченьки = (
			СостояниеЧтения.КоличествоЗапятых <> Неопределено
			И СостояниеЧтения.ПрочитаноЗапятых >= СостояниеЧтения.КоличествоЗапятых
		);
		
		Если ФинальноеДействие.ЗаписатьИмяПеченьки Тогда
			СостояниеАтрибута.Построитель.Удалить(СостояниеАтрибута.Построитель.ВГраница());
		Иначе
			СостояниеАтрибута.Построитель.Добавить(ЧастьОписанияПеченья(ОписанияПеченья.Нормализованное, СостояниеЧтения));
		КонецЕсли;
		
		СостояниеАтрибута.Объект.Значение = СтрСоединить(СостояниеАтрибута.Построитель);
		СостояниеПеченьки.Объект.Атрибуты.Добавить(СостояниеАтрибута.Объект);
		Печеньки.Добавить(СостояниеПеченьки.Объект);
		
		Если ФинальноеДействие.ЗаписатьИмяПеченьки Тогда
			СостояниеПеченьки.Объект = НоваяПеченька(); 
		КонецЕсли;
	КонецЕсли;
	
	Если ФинальноеДействие.ЗаписатьИмяПеченьки Тогда
		СостояниеПеченьки.Объект.Имя = СокрЛП(ЧастьОписанияПеченья(ОписанияПеченья.Исходное, СостояниеЧтения, 1));
		Печеньки.Добавить(СостояниеПеченьки.Объект);
	КонецЕсли;
КонецПроцедуры

Функция ЧастьОписанияПеченья(Знач ОписаниеПеченьки, Знач СостояниеЧтения, Знач Смещение = 0)
	Возврат Сред(
		ОписаниеПеченьки,
		СостояниеЧтения.Позиция,
		СостояниеЧтения.Токен.Позиция - СостояниеЧтения.Позиция + Смещение
	);
КонецФункции

Функция СвойстваПеченьки(Знач Имя, Знач Значение, Знач Атрибуты)
	фРезультат = Новый Структура("Имя, Значение", Имя, Значение);
	ОписаниеТипаЧисло = Новый ОписаниеТипов("Число");
	АтрибутКакСвойство = КлиентHTTPПовтИсп.АтрибутыКакСвойства();
	ИмяСрок = КлиентHTTPПовтИсп.СвойствоПеченькаСрок();
	ИмяВремяАктуальности = КлиентHTTPПовтИсп.СвойствоПеченькаВремяАктуальности();
	ИмяАдресРесурса = КлиентHTTPПовтИсп.СвойствоПеченькаАдресРесурса();
	ИмяЗащищенноеСоединение = КлиентHTTPПовтИсп.СвойствоПеченькаЗащищенноеСоединение();
	ТУД = ТекущаяУниверсальнаяДата();
	
	Для Каждого Атрибут Из Атрибуты Цикл
		Ошибка = Ложь;
		
		ИмяСвойства = АтрибутКакСвойство.Получить(Атрибут.Имя);
		Если ИмяСвойства = ИмяСрок Тогда
			ВременнаяМетка = ОписаниеТипаЧисло.ПривестиЗначение(Атрибут.Значение);
			Если ВременнаяМетка > 0 Тогда
				фРезультат.Вставить(ИмяСвойства, КлиентHTTPПовтИсп.ЭпохаUnix() + ВременнаяМетка);
				Продолжить;
			КонецЕсли;
			Срок = КлиентHTTPСлужебный.ДатаИзHTTP(Атрибут.Значение, Ошибка);
			Если НЕ Ошибка Тогда
				фРезультат.Вставить(ИмяСвойства, Срок);
			КонецЕсли;
		ИначеЕсли ИмяСвойства = ИмяВремяАктуальности Тогда
			ВремяАктуальности = ОписаниеТипаЧисло.ПривестиЗначение(СокрЛП(Атрибут.Значение));
			Если ВремяАктуальности > 0 Тогда
				фРезультат.Вставить(ИмяСрок, ТУД + ВремяАктуальности);
			КонецЕсли;
		ИначеЕсли ИмяСвойства = ИмяАдресРесурса Тогда
			Если НЕ ПустаяСтрока(Атрибут.Значение) Тогда
				фРезультат.Вставить(ИмяСвойства, СокрЛП(Атрибут.Значение));
			КонецЕсли;
		ИначеЕсли ИмяСвойства = ИмяЗащищенноеСоединение Тогда
			фРезультат.Вставить(ИмяСвойства);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Новый ФиксированнаяСтруктура(фРезультат);
КонецФункции

Функция ПозицииТокеновПеченья(Знач ОписаниеПеченья)
	фРезультат = Новый Массив;
	
	КЧ = Новый КвалификаторыЧисла(10, 0, ДопустимыйЗнак.Неотрицательный);
	
	ОТЧ = Новый ОписаниеТипов("Число", КЧ);
	ОТС = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(20, ДопустимаяДлина.Переменная));
	ОТЧН = Новый ОписаниеТипов("Null, Число", КЧ);
	
	ПозицииТокенов = Новый ТаблицаЗначений;
	ПозицииТокенов.Колонки.Добавить("Позиция", ОТЧ);
	ПозицииТокенов.Колонки.Добавить("Токен", ОТС);
	ПозицииТокенов.Колонки.Добавить("ТипТокена", ОТЧ);
	ПозицииТокенов.Колонки.Добавить("Смещение", ОТЧ);
	ПозицииТокенов.Колонки.Добавить("КоличествоЗапятых", ОТЧН);
	
	ИменаКолонок = Новый Массив;
	Для Каждого Колонка Из ПозицииТокенов.Колонки Цикл
		ИменаКолонок.Добавить(Колонка.Имя);
	КонецЦикла;
	ИменаПолей = СтрСоединить(ИменаКолонок, ",");
	
	ДлинаОписания = СтрДлина(ОписаниеПеченья);
	Поиск = Новый Структура("НачальнаяПозиция, Позиция, Токен, ТипТокена, Смещение, КоличествоЗапятых");
	
	Для Каждого Токен Из КлиентHTTPПовтИсп.ТокеныПарсингаПеченья() Цикл
		ДлинаТокена = СтрДлина(Токен.Значение);
		
		Поиск.Токен = Токен.Значение;
		Поиск.ТипТокена = Токен.Тип;
		Поиск.НачальнаяПозиция  = 1;
		Поиск.Позиция = СтрНайти(ОписаниеПеченья, Поиск.Токен, , Поиск.НачальнаяПозиция);
		Поиск.Смещение = Токен.Смещение;
		Поиск.КоличествоЗапятых = Токен.КоличествоЗапятых;
		
		Пока Поиск.Позиция > 0 Цикл
			ЗаполнитьЗначенияСвойств(ПозицииТокенов.Добавить(), Поиск);
			
			Поиск.НачальнаяПозиция = Поиск.Позиция + ДлинаТокена;
			Если Поиск.НачальнаяПозиция > ДлинаОписания Тогда
				Прервать;
			КонецЕсли;
			
			Поиск.Позиция = СтрНайти(ОписаниеПеченья, Поиск.Токен, , Поиск.НачальнаяПозиция);
		КонецЦикла;
	КонецЦикла;

	ПозицииТокенов.Сортировать("Позиция");
	
	Для Каждого Стр Из ПозицииТокенов Цикл
		ПозицияТокена = Новый Структура(ИменаПолей);
		ЗаполнитьЗначенияСвойств(ПозицияТокена, Стр);
		фРезультат.Добавить(Новый ФиксированнаяСтруктура(ПозицияТокена));
	КонецЦикла;
	
	Возврат Новый ФиксированныйМассив(фРезультат);
КонецФункции

Функция ХешСтрока(Знач Данные, Знач Алгоритм)
	ТипФункции = ТипХешФункции(Алгоритм);
	
	Если ТипЗнч(Данные) = Тип("Строка") Тогда
		Данные = ПолучитьДвоичныеДанныеИзСтроки(Данные, КлиентHTTPПовтИсп.КодировкаUTF8(), Ложь);
	КонецЕсли;
	
	Хеширование = Новый ХешированиеДанных(ТипФункции);
	Хеширование.Добавить(Данные);
	
	Возврат НРег(ПолучитьHexСтрокуИзДвоичныхДанных(Хеширование.ХешСумма));
КонецФункции

Функция ТипХешФункции(Знач Алгоритм)
	фРезультат = ?(
		ЗначениеЗаполнено(Алгоритм),
		КлиентHTTPСерверПовтИсп.ПоддерживаемыеТипыХешФункций().Получить(НРег(Алгоритм)),
		ХешФункция.MD5
	);
	Если фРезультат = Неопределено Тогда
		ВызватьИсключение "Неизвестный тип хеш-функции";
	КонецЕсли;

	Возврат фРезультат;
КонецФункции

Функция ТелоОтвета(Ответ, ДополнительныеПараметры)
	ДанныеТелаОтвета = ?(
		КлиентHTTPКлиентСервер.ЗначениеЗаголовка(КлиентHTTPПовтИсп.ЗаголовокОтветаСжатиеТела(), Ответ.Заголовки) = Неопределено,
		Ответ.ПолучитьТелоКакДвоичныеДанные(),
		Декомпрессия(Ответ.ПолучитьТелоКакПоток())
	);
	
	Возврат ?(
		ДополнительныеПараметры.Свойство("ПрочитатьТелоОтветаКак"),
		КлиентHTTPКлиентСервер.ПреобразованноеТелоОтвета(Ответ, ДанныеТелаОтвета, ДополнительныеПараметры.ПрочитатьТелоОтветаКак),
		ДанныеТелаОтвета
	);
КонецФункции

Функция Декомпрессия(Знач ПотокСжатыхДанных)
#Если МобильноеПриложениеСервер Тогда
	ВызватьИсключение "Функционал не поддерживается в мобильном приложении";
#Иначе
	ИмяФайлаВАрхиве = ПолучитьБуферДвоичныхДанныхИзСтроки(Сред(Новый УникальныйИдентификатор, 25), КодировкаТекста.ANSI, Ложь);
	РазмерСжатыхДанных = ПотокСжатыхДанных.Размер() - 18; // размер префикса + размер постфикса GZip = 18
	
	// Восстановление структуры ZIP-архива
	
	ОбластиZIP = КлиентHTTPПовтИсп.ОбластиФайлаВАрхивеZIP();
	Поток = Новый ПотокВПамяти(ОбластиZIP.РазмерLFH + РазмерСжатыхДанных + ОбластиZIP.РазмерDD + ОбластиZIP.РазмерCDFH + ОбластиZIP.РазмерEOCD);
	
	ОбластиZIP.ОбластьLFH.Записать(30, ИмяФайлаВАрхиве);
	
	Чтение = Новый ЧтениеДанных(ПотокСжатыхДанных);
	Чтение.Пропустить(10); // размер префикса GZip
	
	Запись = Новый ЗаписьДанных(Поток);
	Запись.ЗаписатьБуферДвоичныхДанных(ОбластиZIP.ОбластьLFH);
	Чтение.КопироватьВ(Запись, РазмерСжатыхДанных);
	Запись.Закрыть();
	
	КонтрольнаяСумма = Чтение.ПрочитатьЦелое32();
	РазмерНесжатыхДанных = Чтение.ПрочитатьЦелое32();
	
	Чтение.Закрыть();
	
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(4, КонтрольнаяСумма);
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(8, РазмерСжатыхДанных);
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(12, РазмерНесжатыхДанных);

	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(16, КонтрольнаяСумма);
	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(20, РазмерСжатыхДанных);
	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(24, РазмерНесжатыхДанных);
	ОбластиZIP.ОбластьCDFH.Записать(46, ИмяФайлаВАрхиве);

	ОбластиZIP.ОбластьEOCD.ЗаписатьЦелое32(16, ОбластиZIP.РазмерLFH + РазмерСжатыхДанных + ОбластиZIP.РазмерDD);
	
	Запись = Новый ЗаписьДанных(Поток);
	Запись.ЗаписатьБуферДвоичныхДанных(ОбластиZIP.ОбластьDD);
	Запись.ЗаписатьБуферДвоичныхДанных(ОбластиZIP.ОбластьCDFH);
	Запись.ЗаписатьБуферДвоичныхДанных(ОбластиZIP.ОбластьEOCD);
	Запись.Закрыть();
	
	// Извлечение содержимого ZIP-архива
	
	Каталог = ПолучитьИмяВременногоФайла();
	Чтение = Новый ЧтениеZipФайла(Поток);
	ИмяФайла = Чтение.Элементы[0].Имя;
	Чтение.Извлечь(Чтение.Элементы[0], Каталог, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	Чтение.Закрыть();
	
	фРезультат = Новый ДвоичныеДанные(Каталог + ПолучитьРазделительПути() + ИмяФайла);
	Попытка
		УдалитьФайлы(Каталог);
	Исключение
		СобытиеВТранзакции = Ложь;
		КлиентHTTPВызовСервера.ДобавитьЗаписьОшибкиВЖурналРегистрации(Каталог, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()), СобытиеВТранзакции);
		Если СобытиеВТранзакции Тогда
			ВызватьИсключение ОписаниеОшибки();
		КонецЕсли;
	КонецПопытки;
	
	Возврат фРезультат;
#КонецЕсли
КонецФункции

Процедура ДобавитьДанныеФормыТекст(ПолеФормы, ЗаписьДанныхФормы)
	ЗаписьДанныхФормы.ЗаписатьСтроку(СтрШаблон("Content-Disposition: form-data; name=""%1""", ПолеФормы.Ключ));
	
	Если ПолеФормы.Свойство("ТипMIME") Тогда
		ЗаписьДанныхФормы.ЗаписатьСтроку("Content-Type: " + ПолеФормы.ТипMIME);
	КонецЕсли;
	Если ПолеФормы.Свойство("Кодировка") Тогда
		ЗаписьДанныхФормы.ЗаписатьСтроку("Content-Transfer-Encoding: " + ПолеФормы.Файл.Кодировка);
	КонецЕсли;
	ЗаписьДанныхФормы.ЗаписатьСтроку("");
	ЗаписьДанныхФормы.ЗаписатьСтроку(ПолеФормы.Значение);
КонецПроцедуры

Процедура ДобавитьДанныеФормыФайл(ПолеФормы, ЗаписьДанныхФормы)
	СтрокаПоля = СтрШаблон("Content-Disposition: form-data; name=""%1""", ПолеФормы.Ключ);
	
	ИмяФайла = ?(ПолеФормы.Файл.Свойство("ИмяФайла"), ПолеФормы.Файл.ИмяФайла, ПолеФормы.Значение.Имя);
	Если НЕ ПустаяСтрока(ИмяФайла) Тогда
		СтрокаПоля = СтрШаблон("%1; filename=""%2""", СтрокаПоля, ИмяФайла);
	КонецЕсли;
	
	ЗаписьДанныхФормы.ЗаписатьСтроку(СтрокаПоля);
	Если ПолеФормы.Файл.Свойство("ТипMIME") Тогда
		ЗаписьДанныхФормы.ЗаписатьСтроку("Content-Type: " + ПолеФормы.Файл.ТипMIME);
	КонецЕсли;
	Если ПолеФормы.Файл.Свойство("Кодировка") Тогда
		ЗаписьДанныхФормы.ЗаписатьСтроку("Content-Transfer-Encoding: " + ПолеФормы.Файл.Кодировка);
	КонецЕсли;
	ЗаписьДанныхФормы.ЗаписатьСтроку("");
	ЗаписьДанныхФормы.Записать(Новый ДвоичныеДанные(ПолеФормы.Значение.ПолноеИмя));
	ЗаписьДанныхФормы.ЗаписатьСтроку("");
КонецПроцедуры
#КонецОбласти
