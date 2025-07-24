# 📦 Envanter, Satış ve Stok Tahmini Sistemi (SQL Server)

## 📌 Proje Tanımı
Bu proje, SQL Server kullanılarak geliştirilmiş bir **Envanter, Satış ve Stok Tahmini Yönetim Sistemidir**.  
Amaç, ürün stoklarını, satış performansını ve stok tükenme ihtimalini analiz ederek daha bilinçli kararlar almayı sağlamaktır.

## 🎯 Hedefler
- Satış ve stok verilerini merkezi olarak izlemek  
- Kritik stok seviyelerini belirlemek  
- Satış trendlerini analiz etmek  
- Tahmini stok tükenme süresini hesaplamak  
- Tedarik ve sipariş süreçlerini iyileştirmek

---

## 🧱 Veritabanı Yapısı

### 🔹 Tablolar
- `Products`: Ürün bilgileri ve stok durumu  
- `Sales`: Satış kayıtları  
- `Shipments`: Tedarik edilen ürünler  
- `Suppliers`: Tedarikçi bilgileri  

### 🔗 İlişkiler
- `Sales.ProductID` → `Products.ProductID`  
- `Shipments.ProductID` → `Products.ProductID`  
- `Shipments.SupplierID` → `Suppliers.SupplierID`

---

## ⚙️ Teknolojiler
- SQL Server 2019  
- SQL Server Management Studio (SSMS)  
- T-SQL (Transact-SQL)

---

## 📊 Örnek Raporlama Sorguları

### ✅ En çok satılan ürünler
```sql
SELECT TOP 5 P.ProductName, SUM(S.QuantitySold) AS TotalSold
FROM Sales S
JOIN Products P ON S.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalSold DESC;


📈 Proje Katkısı
Bu proje, SQL Server ile:

Gerçek hayat envanter-satış sistemlerine yönelik modelleme yapmayı,

İlişkisel veritabanı kurmayı ve yönetmeyi,

T-SQL ile analitik sorgular yazmayı öğrenmenizi sağlar.

Veriye dayalı karar süreçlerine katkı sunan başarılı bir örnektir.
🧑‍💻 Geliştiren Rümeysa Türken
📍 İstanbul
🎓 Yönetim Bilişim Sistemleri


