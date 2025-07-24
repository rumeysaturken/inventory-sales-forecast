/*
Tablolar�n Olu�turulmas�
  Suppliers: Tedarik�i bilgileri (firma ad�, ileti�im)
  Products: �r�n bilgileri (isim, fiyat, stok, hangi tedarik�iden)
  Shipments: Gelen �r�n sevkiyatlar� (�r�n, tedarik�i, miktar, tarih)
  Sales: Sat�� kay�tlar� (�r�n, miktar, sat�� tarihi)*/



DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Shipments;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;


CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100),
    ContactInfo NVARCHAR(100)
);
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100),
    SupplierID INT,
    Price DECIMAL(10,2),
    StockQuantity INT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    SupplierID INT,
    Quantity INT,
    ShipmentDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    Quantity INT,
    SaleDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

/* 
Veri Ekleme
INSERT INTO Suppliers ...
INSERT INTO Products ...
INSERT INTO Shipments ...
INSERT INTO Sales ...
�rnek tedarik�i, �r�n, sevkiyat ve sat�� verileri ekleniyor.
B�ylece proje test edilebilecek ger�ek�i verilerle �al���yor.
*/
INSERT INTO Suppliers (SupplierName, ContactInfo) VALUES
('ABC Ltd', 'abc@example.com'),
('XYZ Corp', 'xyz@example.com');

INSERT INTO Products (ProductName, SupplierID, Price, StockQuantity) VALUES
('Laptop', 1, 15000.00, 20),
('Fare', 2, 250.00, 100),
('Klavye', 2, 500.00, 80),
('Monit�r', 1, 3000.00, 40);

INSERT INTO Shipments (ProductID, SupplierID, Quantity, ShipmentDate) VALUES
(1, 1, 10, '2025-07-22');

INSERT INTO Sales (ProductID, Quantity, SaleDate) VALUES
(1, 2, '2025-07-22');

/*
CREATE TRIGGER trg_UpdateStockOnSale ON Sales AFTER INSERT AS ...
CREATE TRIGGER trg_UpdateStockOnShipment ON Shipments AFTER INSERT AS ...
Sat�� yap�ld���nda otomatik olarak ilgili �r�n�n stok miktar�n� azalt�r.
Sevkiyat geldi�inde otomatik stok miktar�n� art�r�r.
B�ylece stok her zaman g�ncel tutulur, manuel m�dahaleye gerek kalmaz.
*/
-- �nce varsa eski trigger'� sil
IF OBJECT_ID('trg_UpdateStockOnSale', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateStockOnSale;
GO

-- Sonra yeni trigger'� olu�tur
CREATE TRIGGER trg_UpdateStockOnSale
ON Sales
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.StockQuantity = p.StockQuantity - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

IF OBJECT_ID('trg_UpdateStockOnShipment', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateStockOnShipment;
GO

CREATE TRIGGER trg_UpdateStockOnShipment
ON Shipments
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.StockQuantity = p.StockQuantity + i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO
/*
Raporlama Sorgular�
En �ok satan �r�n: Sat�� miktar�na g�re en pop�ler �r�n� bulur.

Stok durumu: �r�nlerin g�ncel stok miktarlar�n� g�sterir.

Belirli tarih aral���nda sat��: Son 30 g�nde hangi �r�n ne kadar sat�lm��, ka� g�n sat�� olmu�.

Tedarik�i bazl� sevkiyat: Hangi tedarik�i ne kadar �r�n g�ndermi�, ka� sevkiyat yap�lm��.

Stokta azalan �r�nler: Stok miktar� kritik seviyenin alt�nda olan �r�nleri listeler.

*/

/*
Ama� ve Faydalar
Envanter kontrol� kolayla��r: Hangi �r�nden ne kadar kald�, h�zl�ca g�r�l�r.

Sat�� ve tedarik takibi yap�l�r: En �ok sat�lan �r�nler, tedarik�i performanslar� izlenir.

Otomatik stok g�ncelleme: Hatalar ve manuel giri� y�k� azal�r.

Karar destek: Verilere dayal� stok yenileme ve sat�� stratejileri geli�tirilebilir.


*/
INSERT INTO Shipments (ProductID, Quantity, ShipmentDate)
VALUES (1, 20, GETDATE());

INSERT INTO Sales (ProductID, Quantity, SaleDate)
VALUES (1, 5, GETDATE());

SELECT ProductID, ProductName, StockQuantity
FROM Products;

INSERT INTO Shipments (ProductID, Quantity, ShipmentDate)
VALUES (1, 20, GETDATE());

SELECT ProductID, ProductName, StockQuantity
FROM Products;

INSERT INTO Sales (ProductID, Quantity, SaleDate)
VALUES (1, 5, GETDATE());

SELECT ProductID, ProductName, StockQuantity
FROM Products;

SELECT TOP 1 
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalSold
FROM 
    Sales s
JOIN 
    Products p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSold DESC;

	SELECT 
    ProductID,
    ProductName,
    StockQuantity AS RemainingStock
FROM 
    Products;

	--en cok sat�lan 5 �r�n
	SELECT TOP 5
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalSold
FROM 
    Sales s
JOIN 
    Products p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSold DESC;

	--Her �r�n�n toplam sat��� ve g�ncel stok durumu
	SELECT 
    p.ProductID,
    p.ProductName,
    ISNULL(SUM(s.Quantity), 0) AS TotalSold,
    p.StockQuantity AS RemainingStock
FROM 
    Products p
LEFT JOIN 
    Sales s ON p.ProductID = s.ProductID
GROUP BY 
    p.ProductID, p.ProductName, p.StockQuantity
ORDER BY 
    p.ProductName;

	--Belirli bir tarih aral���nda sat�� raporu
	--Mesela son 30 g�n i�indeki sat��lar� g�rmek i�in:
	SELECT 
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalSold,
    COUNT(DISTINCT s.SaleDate) AS SaleDays
FROM 
    Sales s
JOIN 
    Products p ON s.ProductID = p.ProductID
WHERE 
    s.SaleDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSold DESC;

	--Tedarik�i baz�nda toplam �r�n miktar� ve sevkiyat say�s�
	SELECT 
    sup.SupplierID,
    sup.SupplierName,
    COUNT(DISTINCT sh.ShipmentID) AS ShipmentCount,
    SUM(sh.Quantity) AS TotalShipmentQuantity
FROM 
    Suppliers sup
LEFT JOIN 
    Shipments sh ON sup.SupplierID = sh.SupplierID
GROUP BY 
    sup.SupplierID, sup.SupplierName
ORDER BY 
    TotalShipmentQuantity DESC;

	--Stokta azalan �r�nler (stok miktar� 10�dan az olanlar)
	SELECT 
    ProductID,
    ProductName,
    StockQuantity
FROM 
    Products
WHERE 
    StockQuantity < 10
ORDER BY 
    StockQuantity ASC;
	--en cok sat�lan �r�n� bulmak 
	SELECT TOP 1
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalSold
FROM 
    Sales s
JOIN 
    Products p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSold DESC;

	--�r�nlerin G�ncel Stok Miktarlar�n� G�rmek
	SELECT 
    ProductID,
    ProductName,
    StockQuantity AS RemainingStock
FROM 
    Products;

	--En �ok Satan �lk 5 �r�n� G�rmek
	SELECT TOP 5
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalSold
FROM 
    Sales s
JOIN 
    Products p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSold DESC;

	-- Belirli Tarih Aral���nda Sat�� Raporu
	SELECT 
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalSold,
    COUNT(DISTINCT s.SaleDate) AS SaleDays
FROM 
    Sales s
JOIN 
    Products p ON s.ProductID = p.ProductID
WHERE 
    s.SaleDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSold DESC;

	--Tedarik�i Baz�nda Toplam �r�n Miktar� ve Sevkiyat Say�s�
	SELECT 
    sup.SupplierID,
    sup.SupplierName,
    COUNT(DISTINCT sh.ShipmentID) AS ShipmentCount,
    SUM(sh.Quantity) AS TotalShipmentQuantity
FROM 
    Suppliers sup
LEFT JOIN 
    Shipments sh ON sup.SupplierID = sh.SupplierID
GROUP BY 
    sup.SupplierID, sup.SupplierName
ORDER BY 
    TotalShipmentQuantity DESC;
