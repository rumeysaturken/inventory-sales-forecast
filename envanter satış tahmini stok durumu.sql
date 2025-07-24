/*
Tablolarýn Oluþturulmasý
  Suppliers: Tedarikçi bilgileri (firma adý, iletiþim)
  Products: Ürün bilgileri (isim, fiyat, stok, hangi tedarikçiden)
  Shipments: Gelen ürün sevkiyatlarý (ürün, tedarikçi, miktar, tarih)
  Sales: Satýþ kayýtlarý (ürün, miktar, satýþ tarihi)*/



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
Örnek tedarikçi, ürün, sevkiyat ve satýþ verileri ekleniyor.
Böylece proje test edilebilecek gerçekçi verilerle çalýþýyor.
*/
INSERT INTO Suppliers (SupplierName, ContactInfo) VALUES
('ABC Ltd', 'abc@example.com'),
('XYZ Corp', 'xyz@example.com');

INSERT INTO Products (ProductName, SupplierID, Price, StockQuantity) VALUES
('Laptop', 1, 15000.00, 20),
('Fare', 2, 250.00, 100),
('Klavye', 2, 500.00, 80),
('Monitör', 1, 3000.00, 40);

INSERT INTO Shipments (ProductID, SupplierID, Quantity, ShipmentDate) VALUES
(1, 1, 10, '2025-07-22');

INSERT INTO Sales (ProductID, Quantity, SaleDate) VALUES
(1, 2, '2025-07-22');

/*
CREATE TRIGGER trg_UpdateStockOnSale ON Sales AFTER INSERT AS ...
CREATE TRIGGER trg_UpdateStockOnShipment ON Shipments AFTER INSERT AS ...
Satýþ yapýldýðýnda otomatik olarak ilgili ürünün stok miktarýný azaltýr.
Sevkiyat geldiðinde otomatik stok miktarýný artýrýr.
Böylece stok her zaman güncel tutulur, manuel müdahaleye gerek kalmaz.
*/
-- Önce varsa eski trigger'ý sil
IF OBJECT_ID('trg_UpdateStockOnSale', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateStockOnSale;
GO

-- Sonra yeni trigger'ý oluþtur
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
Raporlama Sorgularý
En çok satan ürün: Satýþ miktarýna göre en popüler ürünü bulur.

Stok durumu: Ürünlerin güncel stok miktarlarýný gösterir.

Belirli tarih aralýðýnda satýþ: Son 30 günde hangi ürün ne kadar satýlmýþ, kaç gün satýþ olmuþ.

Tedarikçi bazlý sevkiyat: Hangi tedarikçi ne kadar ürün göndermiþ, kaç sevkiyat yapýlmýþ.

Stokta azalan ürünler: Stok miktarý kritik seviyenin altýnda olan ürünleri listeler.

*/

/*
Amaç ve Faydalar
Envanter kontrolü kolaylaþýr: Hangi üründen ne kadar kaldý, hýzlýca görülür.

Satýþ ve tedarik takibi yapýlýr: En çok satýlan ürünler, tedarikçi performanslarý izlenir.

Otomatik stok güncelleme: Hatalar ve manuel giriþ yükü azalýr.

Karar destek: Verilere dayalý stok yenileme ve satýþ stratejileri geliþtirilebilir.


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

	--en cok satýlan 5 ürün
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

	--Her ürünün toplam satýþý ve güncel stok durumu
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

	--Belirli bir tarih aralýðýnda satýþ raporu
	--Mesela son 30 gün içindeki satýþlarý görmek için:
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

	--Tedarikçi bazýnda toplam ürün miktarý ve sevkiyat sayýsý
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

	--Stokta azalan ürünler (stok miktarý 10’dan az olanlar)
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
	--en cok satýlan ürünü bulmak 
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

	--Ürünlerin Güncel Stok Miktarlarýný Görmek
	SELECT 
    ProductID,
    ProductName,
    StockQuantity AS RemainingStock
FROM 
    Products;

	--En Çok Satan Ýlk 5 Ürünü Görmek
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

	-- Belirli Tarih Aralýðýnda Satýþ Raporu
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

	--Tedarikçi Bazýnda Toplam Ürün Miktarý ve Sevkiyat Sayýsý
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
