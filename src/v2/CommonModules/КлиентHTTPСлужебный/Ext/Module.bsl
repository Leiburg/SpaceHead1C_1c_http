﻿
// SPDX-License-Identifier: Apache-2.0+

#Область ПрограммныйИнтерфейс
// Возвращает размер текстовых данных в байтах (с учётом кодировки)
//
// Параметры:
//  Текст		 - Строка					 - текстовые данные
//  Кодировка	 - Строка, КодировкаТекста	 - кодировка текстовых данных
// 
// Возвращаемое значение:
//  Число - размер текстовых данных в байтах
//
Функция РазмерТекстовыхДанных(Знач Текст, Знач Кодировка = Неопределено) Экспорт
	Кодировка = ?(Кодировка = Неопределено, КлиентHTTPПовтИсп.КодировкаПоУмолчанию(), Кодировка);
	
	Возврат ПолучитьДвоичныеДанныеИзСтроки(Текст, Кодировка).Размер();
КонецФункции

// Возвращает строку Basic-аутентификации для пользователя и пароля
//
// Параметры:
//  Пользователь - Строка	 - Пользователь
//  Пароль		 - Строка	 - Пароль
// 
// Возвращаемое значение:
//  Строка - значение Basic-авторизации
//
Функция СтрокаBasicАвторизации(Знач Пользователь, Знач Пароль) Экспорт
	Возврат СтрЗаменить(
		Base64Строка(ПолучитьДвоичныеДанныеИзСтроки(Пользователь + ":" + Пароль)),
		Символы.ВК + Символы.ПС,
		""
	);
КонецФункции

// Возвращает MIME-тип по расширению файла
//
// Параметры:
//  РасширениеФайла	 - Строка	 - расширение файла
// 
// Возвращаемое значение:
//  Строка - MIME-тип
//
Функция ТипMIMEРасширенияФайла(Знач РасширениеФайла) Экспорт
	Если СтрНачинаетсяС(РасширениеФайла, ".") Тогда
		РасширениеФайла = Прав(РасширениеФайла, СтрДлина(РасширениеФайла) - 1);
	КонецЕсли;
	
	ТипMIME = КлиентHTTPПовтИсп.ТипыMIMEРасширенийФайлов().Получить(НРег(РасширениеФайла));
	
	Возврат ?(ТипMIME = Неопределено, КлиентHTTPПовтИсп.ТипMIMEOctetStream(), ТипMIME);
КонецФункции

// Возвращает дату, полученную из текстового представления даты RFC 1123
//
// Параметры:
//  ДатаHTTP - Строка	 - конвертируемое значение
//  Ошибка	 - Булево	 - флаг ошибки конвертации
// 
// Возвращаемое значение:
//  Дата, Неопределено - значение даты
//
Функция ДатаИзHTTP(Знач ДатаHTTP, Ошибка) Экспорт
	фРезультат = Неопределено;
	ОписаниеТипаЧисло = Новый ОписаниеТипов("Число");
	ДатаHTTP = НРег(СокрЛП(ДатаHTTP));
	Месяцы = СтрРазделить("jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec", ",");
	
	Для Каждого Токен Из СтрРазделить(",|:|-", "|") Цикл
		ДатаHTTP = СтрЗаменить(ДатаHTTP, Токен, " ");
	КонецЦикла;
	
	Пока СтрНайти(ДатаHTTP, "  ") > 0 Цикл
		ДатаHTTP = СтрЗаменить(ДатаHTTP, "  ", " ");
	КонецЦикла;
	
	ЧастиДатыHTTP = СтрРазделить(ДатаHTTP, " ");
	Если ЧастиДатыHTTP.Количество() < 7 Тогда
		Ошибка = Истина;
		Возврат фРезультат;
	КонецЕсли;
	
	Год = ОписаниеТипаЧисло.ПривестиЗначение(ЧастиДатыHTTP[3]);
	Если Год < 70 Тогда
		Год = 2000 + Год;
	ИначеЕсли Год < 100 Тогда
		Год = 1900 + Год;
	КонецЕсли;
	
	Месяц = Месяцы.Найти(ЧастиДатыHTTP[2]);
	Если Месяц = Неопределено Тогда
		Ошибка = Истина;
		Возврат фРезультат;
	КонецЕсли;
	
	День = ОписаниеТипаЧисло.ПривестиЗначение(ЧастиДатыHTTP[1]);
	Если День = 0 Тогда
		Ошибка = Истина;
		Возврат фРезультат;
	КонецЕсли;
	
	фРезультат = Дата(
		Год,
		Месяц + 1,
		День,
		ОписаниеТипаЧисло.ПривестиЗначение(ЧастиДатыHTTP[4]),
		ОписаниеТипаЧисло.ПривестиЗначение(ЧастиДатыHTTP[5]),
		ОписаниеТипаЧисло.ПривестиЗначение(ЧастиДатыHTTP[6])
	);
	
	Возврат фРезультат;
КонецФункции

// Возвращает текстовое представление даты RFC 1123
//  Date: Tue, 15-Nov-1994 08:12:31 GMT
//
// Параметры:
//  Дата - Дата	 - конвертируемое значение
// 
// Возвращаемое значение:
//  Строка - дата формата RFC 1123
//
Функция ДатаВHTTP(Знач Дата) Экспорт
	Возврат СтрШаблон(
		Формат(Дата, "ДФ='""%1"", дд-""%2""-гггг Ч:м:с ""GMT""'"),
		ДеньНеделиНаАнглийском(Дата),
		МесяцНаАнглийском(Дата)
	);
КонецФункции

// Возвращает текстовое представление даты RFC 7231 (7.1.1.2)
//  Date: Tue, 15 Nov 1994 08:12:31 GMT
//
// Параметры:
//  Дата - Дата	 - конвертируемое значение
// 
// Возвращаемое значение:
//  Строка - дата формата RFC 7231 (7.1.1.2)
//
Функция ДатаВHTTP7231(Знач Дата) Экспорт
	Возврат СтрШаблон(
		Формат(Дата, "ДФ='""%1"", дд ""%2"" гггг Ч:м:с ""GMT""'"),
		ДеньНеделиНаАнглийском(Дата),
		МесяцНаАнглийском(Дата)
	);
КонецФункции

// Возвращает преобразованный в ACE-последовательность IDN
//
// Параметры:
//  АдресСервера - Строка	 - IDN
// 
// Возвращаемое значение:
//  Строка - ACE-последовательность
//
Функция НормализованныйАдресСервера(Знач АдресСервера) Экспорт
	Возврат КодироватьАдресСервера(НРег(СокрЛП(АдресСервера)));
КонецФункции

// Возвращает имя параметра запроса с экранированием
//
// Параметры:
//  Имя	 - Строка	 - имя параметра запроса
// 
// Возвращаемое значение:
//  Строка - экранированное имя параметра запроса
//
Функция ФорматированноеИмяПараметраЗапроса(Знач Имя) Экспорт
	Возврат СтрЗаменить(ФорматированноеЗначениеПараметраЗапроса(Имя), "=", "%3D");
КонецФункции

// Возвращает значение параметра запроса с экранированием
//
// Параметры:
//  Значение - Строка	 - значение параметра запроса
// 
// Возвращаемое значение:
//  Строка - экранированное значение параметра запроса
//
Функция ФорматированноеЗначениеПараметраЗапроса(Знач Значение) Экспорт
	Возврат СтрЗаменить(СтрЗаменить(СтрЗаменить(СокрЛП(Значение), Символы.ПС, ""), "#", "%23"), "&", "%26");
КонецФункции
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Функция КодироватьАдресСервера(Знач АдресСервера)
	фРезультат = Новый Массив;
	Префикс = "xn--";
	
	Для Каждого Домен Из СтрРазделить(АдресСервера, ".", Ложь) Цикл
		ЕстьНеASCII = Ложь;
		Для я = 1 По СтрДлина(Домен) Цикл
			ЕстьНеASCII = НЕ ЭтоСимволASCII(КодСимвола(Домен, я));
			Если ЕстьНеASCII Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		фРезультат.Добавить(
			?(
				ЕстьНеASCII,
				Префикс + PunycodeЗначение(Домен),
				Домен
			)
		);
	КонецЦикла;
	
	Возврат ?(Лев(АдресСервера, 1) = ".", ".", "") + СтрСоединить(фРезультат, ".");
КонецФункции

Функция PunycodeЗначение(Знач Строка)
	фРезультат = Новый Массив;
	Параметры = КлиентHTTPПовтИсп.ПараметрыPunycode();
	
	// Начальное состояние
	n = 0; delta = 0; h = 0; b = 0; out = 0; bias = 0; j = 0; m = 0; q = 0; k = 0; t = 0;
	
	n = Параметры.InitialN;
	bias = Параметры.InitialBias;
	ДлинаСтроки = СтрДлина(Строка);
	
	// Обработка символов ASCII
	Для я = 1 По ДлинаСтроки Цикл
		Если ЭтоСимволASCII(КодСимвола(Строка, я)) Тогда
			фРезультат.Добавить(Сред(Строка, я, 1));
			out = out + 1;
		КонецЕсли;
	КонецЦикла;
	
	h = out;
	b = out;
	
	// h is the number of code points that have been handled, b is the
    // number of basic code points, and out is the number of characters
    // that have been output.
	
	Если b > 0 Тогда
		фРезультат.Добавить(Параметры.Delimiter);
		out = out + 1;
	КонецЕсли;
	
	// Кодирование не ASCII символов
	Пока h < ДлинаСтроки Цикл
		m = Параметры.НаибольшееЧисло;
		Для я = 1 По ДлинаСтроки Цикл
			Код = КодСимвола(Строка, я);
			Если Код >= n И Код < m Тогда
				m = Код;
			КонецЕсли;
		КонецЦикла;
		
		// Increase delta enough to advance the decoder's
        // <n,i> state to <m,0>, but guard against overflow:
		Если m - n > Цел((Параметры.НаибольшееЧисло - delta) / (h + 1)) Тогда
			ВызватьИсключение "Punycode: требуется более широкий числовой диапазон для обработки входящих данных";
		КонецЕсли;
		
		delta = delta + (m - n) * (h + 1);
        n = m;
		
		Для я = 1 По ДлинаСтроки Цикл
			Код = КодСимвола(Строка, я);
			Если Код < n Тогда
				delta = delta + 1;
				Если delta = 0 Тогда
					ВызватьИсключение "Punycode: требуется более широкий числовой диапазон для обработки входящих данных";
				КонецЕсли;
			ИначеЕсли Код = n Тогда
				// Represent delta as a generalized variable-length integer
				
				q = delta;
				k = Параметры.Base;
				
				Пока Истина Цикл
					t = ?(
						k <= bias,
						Параметры.TMin,
						?(k >= bias + Параметры.TMax, Параметры.TMax, k - bias)
					);
					Если q < t Тогда
						Прервать;
					КонецЕсли;
					
					фРезультат.Добавить(
						ВСимволPunycode(
							t + (q - t) % (Параметры.Base - t)
						)
					);
					
					out = out + 1;
					q = Цел((q - t) / (Параметры.Base - t));
					k = k + Параметры.Base;
				КонецЦикла;
				
				фРезультат.Добавить(ВСимволPunycode(q));
				
				out = out + 1;
				bias = Адаптация(delta, h + 1, h = b);
				delta = 0;
				h = h + 1;
			КонецЕсли;
		КонецЦикла;
		
		delta = delta + 1;
		n = n + 1;
	КонецЦикла;
	
	Возврат СтрСоединить(фРезультат);
КонецФункции

Функция ЭтоСимволASCII(Знач КодСимвола)
	Возврат КодСимвола < 128; // 0x80
КонецФункции

Функция ВСимволPunycode(Знач Код)
	//  0..25 map to ASCII a..z
    // 26..35 map to ASCII 0..9
	Возврат Символ(Код + 22 + 75 * (Код < 26));
КонецФункции

Функция Адаптация(Знач Дельта, Знач ПозицияСимвола, Знач ПерваяАдаптация)
	Параметры = КлиентHTTPПовтИсп.ПараметрыPunycode();
	
	Дельта = Цел(?(ПерваяАдаптация, Дельта / Параметры.Damp, Дельта / 2));
	Дельта = Дельта + Цел(Дельта / ПозицияСимвола);
	
	ДелительДельты = Параметры.Base - Параметры.TMin;
	Порог = Цел(ДелительДельты * Параметры.TMax / 2);
	База = 0;
	
	Пока Дельта > Порог Цикл
		Дельта = Цел(Дельта / ДелительДельты);
		База = База + Параметры.Base;
	КонецЦикла;
	
	Возврат База + Цел((ДелительДельты + 1) * Дельта / (Дельта + Параметры.Skew));
КонецФункции

Функция ДеньНеделиНаАнглийском(Знач Дата, Знач КороткаяЗапись = Истина)
	Краткое = "Mon,Tue,Wed,Thu,Fri,Sat,Sun";
	Полное  = "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday";
	
	Возврат СтрРазделить(
		?(КороткаяЗапись, Краткое, Полное),
		","
	)[ДеньНедели(Дата)-1];
КонецФункции

Функция МесяцНаАнглийском(Знач Дата, Знач КороткаяЗапись = Истина)
	Краткое = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec";
	Полное  = "January,February,March,April,May,June,July,August,September,October,November,December";
	
	Возврат СтрРазделить(
		?(КороткаяЗапись, Краткое, Полное),
		","
	)[Месяц(Дата)-1];
КонецФункции
#КонецОбласти
