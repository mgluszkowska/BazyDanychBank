USE master;
DROP DATABASE Bank1;
GO

CREATE DATABASE Bank1;
GO

USE Bank1;
GO

SET LANGUAGE polski;
GO

--USUWANIE TABEL

IF OBJECT_ID('Klienci', 'U') IS NOT NULL
    DROP TABLE Klienci;

IF OBJECT_ID('Konta', 'U') IS NOT NULL
    DROP TABLE Konta;

IF OBJECT_ID('Transakcje', 'U') IS NOT NULL
    DROP TABLE Transakcje;

IF OBJECT_ID('Karty', 'U') IS NOT NULL
    DROP TABLE Karty;


--TWORZENIE TABEL

CREATE TABLE Klienci
(
    PESEL       VARCHAR(11) NOT NULL PRIMARY KEY,
    nr_tel	VARCHAR(9)  NOT NULL,
    imie	VARCHAR(20) NOT NULL,
    nazwisko	VARCHAR(20) NOT NULL,
    adres	VARCHAR(40) NOT NULL,
);

CREATE TABLE Konta
(
    numer      	BIGINT IDENTITY(1111111111111101, 1) PRIMARY KEY,
    typ		VARCHAR(20) CHECK (typ in ('osobiste', 'oszczednosciowe')),
    stan 	MONEY DEFAULT 0,
    wlasciciel 	VARCHAR(11) REFERENCES Klienci(PESEL) ON DELETE SET NULL
);

CREATE TABLE Transakcje
(
    numer      		INT IDENTITY(1,1) PRIMARY KEY,
    data_wykonania	DATE,
    kwota 	  	MONEY,
    rodzaj	 	VARCHAR(20) CHECK (rodzaj in ('wplata', 'wyplata')),
    konto		BIGINT REFERENCES Konta(numer)
);


CREATE TABLE Karty
(
    numer        INT IDENTITY(1000000, 1) NOT NULL PRIMARY KEY,
    typ		 VARCHAR(20) 		  NOT NULL CHECK (typ in ('debetowa', 'platnicza')),
    konto        BIGINT REFERENCES Konta(numer) ON DELETE SET NULL
);

GO

--Wyzwalacz, ktory sprawia, ze po wstawieniu jakiegos rekordu to tabeli Transakcje, zmieni sie stan konta w tabeli Konta

CREATE TRIGGER t_transakcja
ON Transakcje
AFTER INSERT
AS
    DECLARE @kwota MONEY;
    SET @kwota = (SELECT kwota FROM inserted);
    DECLARE @konto BIGINT;
    SET @konto = (SELECT konto FROM inserted);
    IF (SELECT rodzaj FROM inserted) = 'wplata'
        UPDATE Konta
        SET    stan = stan + @kwota
        WHERE  numer = @konto;
    ELSE
        UPDATE Konta
        SET    stan = stan - @kwota
        WHERE  numer = @konto;
GO

-- Wyzwalacz INSTEAD OF zabraniający zmieniania danych w transakcjach
GO
CREATE TRIGGER sprawdz_wlasciciela
ON Transakcje
INSTEAD OF  UPDATE
AS 
	PRINT 'Nie można zmienić danych w transakcji';	
GO

-- Wyzwalacz usuwający karty należące do usuniętego konta
GO
CREATE TRIGGER usun_karte_po_koncie
ON Konta
AFTER DELETE
AS
	DECLARE @nr BIGINT;
	SET @nr = (SELECT numer FROM deleted);
	IF EXISTS (SELECT konto FROM Karty WHERE konto=@nr)
	DELETE FROM Karty 
	WHERE konto=@nr;
GO

--Wyzwalacz usuwający konto po usuniętym kliencie
CREATE TRIGGER usun_konto_po_kliencie
ON Klienci
AFTER DELETE
AS
	DECLARE @pesel VARCHAR(11);
	SET @pesel = (SELECT PESEL FROM deleted);
	IF EXISTS (SELECT wlasciciel FROM Konta WHERE wlasciciel=@pesel)
	DELETE FROM Konta 
	WHERE wlasciciel=@pesel;
GO

-- Wypełnienie tabel

INSERT INTO Klienci VALUES
('12345678911', '123456789', 'Stefan', 'Wysocki', 'Krajowa 27'),
('95748365935', '748662866', 'Ewelina', 'Stępa', 'Budziszewska 7 B/11'),
('45528684322', '874232867', 'Roman', 'Rataj', 'Wolności 9'),
('48755268732', '123218635', 'Dorota', 'Piasek', 'Solidarności 89'),
('72662483246', '486423216', 'Marian', 'Dąbek', 'Libelta 2 C/27'),
('69454421155', '753242324', 'Konrad', 'Siekielski', 'Za Cytadelą 27'),
('54868324238', '456657865', 'Anna', 'Kowalska', 'Słowackiego 12'),
('54535865422', '945687203', 'Damian', 'Malisz', 'Mickiewicza 9 A/1'),
('15364975213', '123055462', 'Stanisława', 'Mazurek', 'Wielkopolska 27'),
('54210542156', '456842165', 'Krystian', 'Rębajło', 'Zachodnia 7'),
('65451115615', '146548686', 'Marianna', 'Staniszewska', 'Grunwaldzka 5'),
('86545231565', '486543321', 'Miłosz', 'Rylak', 'Plewicka 98'),
('65451664566', '984565465', 'Patrycja', 'Wylak', 'Chrobrego 10'),
('65489452315', '754226654', 'Natan', 'Moliszek', 'Wesoła 7'),
('35456846544', '356478925', 'Eryka', 'Kozubal', 'Strojna 65'),
('84532156654', '745621651', 'Daniel', 'Zawisza', 'Poznańska 7 B/12'),
('26545684565', '946548620', 'Matylda', 'Garnek', 'Jeżycka 27'),
('54864886215', '522035562', 'Stefan', 'Derka', 'Warszawska 2'),
('65421465456', '945652315', 'Karyna', 'Derka', 'Warszawska 2'),
('25665548955', '856256320', 'Radzisław', 'Cudak', 'Leśnicka 87');

INSERT INTO Konta VALUES
('osobiste', 0, '12345678911'),
('osobiste', 0, '95748365935'),
('osobiste', 0, '45528684322'),
('osobiste', 0, '72662483246'),
('osobiste', 0, '69454421155'),
('osobiste', 0, '54868324238'),
('osobiste', 0, '54535865422'),
('osobiste', 0, '15364975213'),
('osobiste', 0, '65451115615'),
('osobiste', 0, '86545231565'),
('osobiste', 0, '65451664566'),
('osobiste', 0, '35456846544'),
('osobiste', 0, '84532156654'),
('osobiste', 0, '54864886215'),
('osobiste', 0, '25665548955'),
('oszczednosciowe', 0, '25665548955'),
('oszczednosciowe', 0, '26545684565'),
('oszczednosciowe', 0, '65421465456'),
('oszczednosciowe', 0, '86545231565'),
('oszczednosciowe', 0, '69454421155'),
('oszczednosciowe', 0, '45528684322'),
('oszczednosciowe', 0, '12345678911'),
('oszczednosciowe', 0, '54864886215'),
('oszczednosciowe', 0, '72662483246');

INSERT INTO Transakcje VALUES ('20-04-2017', 19.99, 'wplata', 1111111111111101);
INSERT INTO Transakcje VALUES ('20-04-2017', 100.00, 'wplata', 1111111111111102);
INSERT INTO Transakcje VALUES ('21-04-2017', 58.20, 'wplata', 1111111111111103);
INSERT INTO Transakcje VALUES ('21-04-2017', 1000.00, 'wplata', 1111111111111104);
INSERT INTO Transakcje VALUES ('21-04-2017', 32.99, 'wplata', 1111111111111105);
INSERT INTO Transakcje VALUES ('21-05-2017', 50.00, 'wplata', 1111111111111106);
INSERT INTO Transakcje VALUES ('21-05-2018', 100.00, 'wplata', 1111111111111107);
INSERT INTO Transakcje VALUES ('22-05-2018', 200.00, 'wplata', 1111111111111108);
INSERT INTO Transakcje VALUES ('22-05-2017', 50.00, 'wplata', 1111111111111109);
INSERT INTO Transakcje VALUES ('23-05-2018', 300.00, 'wplata', 1111111111111110);
INSERT INTO Transakcje VALUES ('24-05-2018', 30.00, 'wplata', 1111111111111111);
INSERT INTO Transakcje VALUES ('25-05-2018', 450.00, 'wplata', 1111111111111112);
INSERT INTO Transakcje VALUES ('25-05-2017', 500.50, 'wplata', 1111111111111113);
INSERT INTO Transakcje VALUES ('25-06-2018', 453.00, 'wplata', 1111111111111114);
INSERT INTO Transakcje VALUES ('25-06-2018', 300.20, 'wplata', 1111111111111115);
INSERT INTO Transakcje VALUES ('25-06-2018', 50.50, 'wplata', 1111111111111116);
INSERT INTO Transakcje VALUES ('25-07-2017', 160.00, 'wplata', 1111111111111117);
INSERT INTO Transakcje VALUES ('26-07-2018', 19.20, 'wplata', 1111111111111118);
INSERT INTO Transakcje VALUES ('26-07-2018', 160.99, 'wplata', 1111111111111119);
INSERT INTO Transakcje VALUES ('27-07-2018', 260.89, 'wplata', 1111111111111120);
INSERT INTO Transakcje VALUES ('28-08-2018', 19.99, 'wplata', 1111111111111121);
INSERT INTO Transakcje VALUES ('30-09-2018', 100.00, 'wplata', 1111111111111122);
INSERT INTO Transakcje VALUES ('30-09-2018', 480.00, 'wplata', 1111111111111123);
INSERT INTO Transakcje VALUES ('21-06-2018', 5.49, 'wyplata', 1111111111111101);
INSERT INTO Transakcje VALUES ('21-07-2018', 50.09, 'wyplata', 1111111111111102);
INSERT INTO Transakcje VALUES ('21-07-2018', 5.49, 'wyplata', 1111111111111103);
INSERT INTO Transakcje VALUES ('21-07-2017', 10.29, 'wyplata', 1111111111111104);
INSERT INTO Transakcje VALUES ('21-07-2018', 500.00, 'wyplata', 1111111111111105);
INSERT INTO Transakcje VALUES ('21-08-2018', 15.49, 'wyplata', 1111111111111106);
INSERT INTO Transakcje VALUES ('22-09-2018', 20.99, 'wyplata', 1111111111111107);
INSERT INTO Transakcje VALUES ('22-09-2017', 100.49, 'wyplata', 1111111111111108);
INSERT INTO Transakcje VALUES ('22-09-2018', 78.49, 'wyplata', 1111111111111109);
INSERT INTO Transakcje VALUES ('22-09-2018', 90.75, 'wyplata', 1111111111111110);
INSERT INTO Transakcje VALUES ('22-09-2017', 68.09, 'wyplata', 1111111111111111);
INSERT INTO Transakcje VALUES ('23-09-2018', 48.38, 'wyplata', 1111111111111112);
INSERT INTO Transakcje VALUES ('24-10-2018', 93.67, 'wyplata', 1111111111111113);
INSERT INTO Transakcje VALUES ('25-10-2018', 270.49, 'wyplata', 1111111111111114);
INSERT INTO Transakcje VALUES ('26-10-2018', 78.21, 'wyplata', 1111111111111115);
INSERT INTO Transakcje VALUES ('25-10-2018', 79.45, 'wyplata', 1111111111111116);
INSERT INTO Transakcje VALUES ('24-10-2018', 92.78, 'wyplata', 1111111111111102);
INSERT INTO Transakcje VALUES ('25-10-2018', 96.49, 'wyplata', 1111111111111106);
INSERT INTO Transakcje VALUES ('24-10-2018', 340.20, 'wyplata', 1111111111111121);
INSERT INTO Transakcje VALUES ('27-10-2018', 34.09, 'wyplata', 1111111111111105);
INSERT INTO Transakcje VALUES ('28-10-2018', 78.39, 'wyplata', 1111111111111117);
INSERT INTO Transakcje VALUES ('2017-04-20', 19.99, 'wyplata', 1111111111111101);
 
INSERT INTO Karty VALUES
('debetowa', 1111111111111117),
('debetowa', 1111111111111105),
('debetowa', 1111111111111122),
('debetowa', 1111111111111121),
('platnicza', 1111111111111106),
('platnicza', 1111111111111102),
('platnicza', 1111111111111116),
('platnicza', 1111111111111115),
('platnicza', 1111111111111114),
('platnicza', 1111111111111113),
('debetowa', 1111111111111112),
('debetowa', 1111111111111111),
('debetowa', 1111111111111110),
('debetowa', 1111111111111109),
('debetowa', 1111111111111108),
('platnicza', 1111111111111107),
('platnicza', 1111111111111106),
('platnicza', 1111111111111105),
('platnicza', 1111111111111104),
('platnicza', 1111111111111103),
('platnicza', 1111111111111102),
('platnicza', 1111111111111101);

--SELECT
SELECT * FROM Klienci;
SELECT * FROM Konta;
SELECT * FROM Transakcje;
SELECT * FROM Karty;
GO

--widok
CREATE VIEW Historia_transakcji(id, rodzaj_transakcji, kwota, uzyte_konto, data_transakcji)
AS
(
    SELECT numer, rodzaj, kwota, konto, data_wykonania
    FROM Transakcje
);
GO

SELECT * FROM Historia_transakcji;

--funkcja skalarna, ktora oblicza planowany zysk z konta oszczednosciowego po roku
GO
CREATE FUNCTION ufn_planowany_zysk
(
    @pesel_klienta VARCHAR(11)
)
    RETURNS MONEY
AS
BEGIN 
   
    DECLARE @stan_przed MONEY;
    SET @stan_przed =   (SELECT stan FROM Konta 
                        WHERE typ = 'oszczednosciowe' and wlasciciel = @pesel_klienta) 
    RETURN @stan_przed * 1.03;
END;
GO

SELECT dbo.ufn_planowany_zysk(12345678911) as 'Szacowany zysk';

-- Funkcja sprawdzająca stan danego konta
GO
CREATE FUNCTION stan_konta (@nr BIGINT)
RETURNS MONEY
AS
	BEGIN
	RETURN (SELECT stan
	FROM Konta
	WHERE numer=@nr);
	END;
GO

SELECT dbo.stan_konta(1111111111111117);

--funkcja tablicowa zwraca tablicę z danymi o transakcjach z danego konta i okresu czasu
GO
CREATE FUNCTION ufn_transakcje
(
    @pesel      VARCHAR(11),
    @typ_konta  VARCHAR(20),
    @data_pocz  DATE,
    @data_konc  DATE
)
    RETURNS TABLE
AS
    RETURN  SELECT * FROM Historia_transakcji
            WHERE uzyte_konto = (SELECT numer FROM Konta
                        WHERE wlasciciel = @pesel
                        AND typ = @typ_konta)
            AND data_transakcji BETWEEN @data_pocz AND @data_konc;
GO

SELECT * FROM dbo.ufn_transakcje('12345678911', 'osobiste', '1-01-2000', '30-06-2018');
	
-- Procedura do usunięcia klienta
GO
CREATE PROCEDURE usun_klienta
@pesel VARCHAR(11)
AS
	DELETE FROM Klienci
	WHERE PESEL=@pesel;
GO

EXECUTE usun_klienta '12345678911';

-- Procedura do zmiany właściciela konta 
GO
CREATE PROCEDURE usp_zmiana_wlasciciela 
@wlasciciel VARCHAR(11),
@pesel	VARCHAR(11)
AS
	UPDATE Konta
	SET wlasciciel=@pesel
	WHERE wlasciciel=@wlasciciel;
GO

EXECUTE usp_zmiana_wlasciciela '12345678911', '11111111111'; 

-- Procedura do dodania nowego klienta
GO
CREATE PROCEDURE dodaj_klienta
	@pesel      VARCHAR(11),
    @nr_tel		VARCHAR(9),
    @imie		VARCHAR(20),
    @nazwisko	VARCHAR(20),
    @adres		VARCHAR(40)

AS 
	INSERT INTO Klienci VALUES (@pesel, @nr_tel, @imie, @nazwisko, @adres);

EXECUTE dodaj_klienta '11876111111', '126264589', 'Marek', 'Wysocki', 'Krajowa 27';

-- Procedura dodająca konto klientowi
GO
CREATE PROCEDURE dodaj_konto_klientowi

    @typ			VARCHAR(20),
    @stan 	  		MONEY,
    @wlasciciel 	VARCHAR(11)
AS	
	IF EXISTS (SELECT PESEL
				FROM Klienci
				WHERE PESEL=@wlasciciel)
		INSERT INTO Konta VALUES (@typ, @stan, @wlasciciel)
	ELSE
		RAISERROR('Nie ma takiego klienta', 11, 1);

EXECUTE dodaj_konto_klientowi 'oszczednosciowe', 0, '99999999999';

--Procedura zmieniająca numer telefonu klientowi.
GO
CREATE PROCEDURE zmien_nr_tel
	@nr VARCHAR(9),
	@pesel VARCHAR(11)
AS
	IF EXISTS (SELECT PESEL
				FROM Klienci
				WHERE nr_tel=@nr)
	RAISERROR('Podany numer telefonu istnieje już w bazie.', 11, 1)

	ELSE
		UPDATE Klienci
		SET nr_tel = @nr
		WHERE PESEL=@pesel;

EXECUTE zmien_nr_tel '945652315', '11111111111';

-- Procedura zmieniająca adres zamieszkania klienta
GO
CREATE PROCEDURE zmien_adres
	@adres VARCHAR(9),
	@pesel VARCHAR(11)
AS
		UPDATE Klienci
		SET adres = @adres
		WHERE PESEL=@pesel;

EXECUTE zmien_adres 'Jeżycka 2', '11111111111';

-- Procedura dodająca kartę do konta
GO
CREATE PROCEDURE dodaj_karte
    @typ		  VARCHAR(20),
    @konto        BIGINT
AS
	BEGIN TRY
	IF EXISTS (SELECT numer
				FROM Konta
				WHERE numer=@konto)
	    INSERT INTO Karty VALUES(@typ, @konto);
	ELSE
		RAISERROR('Nie istnieje konto o podanym numerze.', 11, 1);
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER()  AS 'NUMER BLEDU',
        ERROR_MESSAGE() AS 'KOMUNIKAT';
	END CATCH;

EXECUTE dodaj_karte 'platnicza', 1029355555555555;

--procedury wykonujące transakcje:
GO
CREATE PROCEDURE wyplata
    @konto BIGINT,
    @kwota MONEY
AS
    IF EXISTS (SELECT numer FROM Konta WHERE numer = @konto)
        BEGIN
            IF ((SELECT stan FROM Konta WHERE numer = @konto)-@kwota > 0)
                INSERT INTO Transakcje VALUES (GETDATE(), @kwota, 'wyplata', @konto);
            ELSE
                RAISERROR('Zbyt malo srodkow na koncie.', 11, 1);
        END
    ELSE
        RAISERROR('Nie istnieje konto o podanym numerze.', 11, 1);
GO    	

SELECT dbo.stan_konta(1111111111111112) as 'stan konta przed wyplata';
EXECUTE wyplata 1111111111111112, 5;
SELECT dbo.stan_konta(1111111111111112) as 'stan konta po wyplacie';

GO
CREATE PROCEDURE wplata
    @konto BIGINT,
    @kwota MONEY
AS
    IF EXISTS (SELECT numer FROM Konta WHERE numer = @konto)
        INSERT INTO Transakcje VALUES (GETDATE(), @kwota, 'wplata', @konto);
    ELSE
        RAISERROR('Nie istnieje konto o podanym numerze.', 11, 1);
GO    	

SELECT dbo.stan_konta(1111111111111112) as 'stan konta przed wplata';
EXECUTE wplata 1111111111111112, 100;
SELECT dbo.stan_konta(1111111111111112) as 'stan konta po wplacie';

GO
CREATE PROCEDURE przelew
    @konto_z BIGINT,
    @konto_na BIGINT,
    @kwota MONEY
AS
    IF EXISTS (SELECT numer FROM Konta WHERE numer = @konto_z) AND EXISTS (SELECT numer FROM Konta WHERE numer = @konto_na)
        BEGIN
            IF ((SELECT stan FROM Konta WHERE numer = @konto_z)-@kwota > 0)
                BEGIN
                INSERT INTO Transakcje VALUES (GETDATE(), @kwota, 'wyplata', @konto_z);
                INSERT INTO Transakcje VALUES (GETDATE(), @kwota, 'wplata', @konto_na);
                END
            ELSE
                RAISERROR('Zbyt malo srodkow na koncie.', 11, 1); 
        END
    ELSE
        RAISERROR('Nie istnieje konto o podanym numerze.', 11, 1);
GO 

SELECT dbo.stan_konta(1111111111111112) as 'konto "z" przed przelewem', dbo.stan_konta(1111111111111111) as 'konto "na" przed przelewem';
EXECUTE przelew 1111111111111112, 1111111111111111, 100;
SELECT dbo.stan_konta(1111111111111112) as 'konto "z" po przelewie', dbo.stan_konta(1111111111111111) as 'konto "na" po przelewie';