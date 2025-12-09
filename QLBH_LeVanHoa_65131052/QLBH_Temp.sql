-- ================================================================
-- PHẦN 1: TẠO DATABASE & BẢNG (FULL CẤU TRÚC 14 BẢNG)
-- ================================================================
USE master;
GO

IF DB_ID(N'QLBH_LeVanHoa_65131052') IS NOT NULL
BEGIN
    ALTER DATABASE QLBH_LeVanHoa_65131052 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLBH_LeVanHoa_65131052;
END
GO

CREATE DATABASE QLBH_LeVanHoa_65131052;
GO
USE QLBH_LeVanHoa_65131052;
GO

-- 1. Nuoc
CREATE TABLE Nuoc (
    MaNuoc VARCHAR(10) PRIMARY KEY,
    TenNuoc NVARCHAR(50) NOT NULL
);
GO

-- 2. NhomSP
CREATE TABLE NhomSP (
    MaNSP VARCHAR(10) PRIMARY KEY,
    TenNSP NVARCHAR(50) NOT NULL
);
GO

-- 3. HangSX
CREATE TABLE HangSX (
    MaHSX VARCHAR(10) PRIMARY KEY,
    TenHSX NVARCHAR(50) NOT NULL,
    MaNuoc VARCHAR(10) NOT NULL,
    CONSTRAINT FK_HangSX_Nuoc FOREIGN KEY (MaNuoc) REFERENCES Nuoc(MaNuoc) ON DELETE CASCADE
);
GO

-- 4. Tinh
CREATE TABLE Tinh (
    MaTinh SMALLINT IDENTITY(1,1) PRIMARY KEY,
    TenTinh NVARCHAR(50) NOT NULL
);
GO

-- 5. Xa
CREATE TABLE Xa (
    MaXa SMALLINT IDENTITY(1,1) PRIMARY KEY,
    TenXa NVARCHAR(50) NOT NULL,
    MaTinh SMALLINT NOT NULL,
    CONSTRAINT FK_Xa_Tinh FOREIGN KEY (MaTinh) REFERENCES Tinh(MaTinh) ON DELETE CASCADE
);
GO

-- 6. NhanVien
CREATE TABLE NhanVien (
    MaNV VARCHAR(20) PRIMARY KEY,
    TenNV NVARCHAR(50) NOT NULL,
    MatKhau VARCHAR(50) NOT NULL,
    DienThoaiNV VARCHAR(15) NULL,
    DiaChiNV NVARCHAR(255) NULL
);
GO

-- 7. NhaCC
CREATE TABLE NhaCC (
    MaNCC VARCHAR(20) PRIMARY KEY,
    TenNCC NVARCHAR(100) NOT NULL,
    DienThoaiNCC VARCHAR(15) NOT NULL,
    EmailNCC VARCHAR(100) NULL,
    DiaChiNCC NVARCHAR(255) NOT NULL,
    MaXa SMALLINT NOT NULL,
    CONSTRAINT FK_NhaCC_Xa FOREIGN KEY (MaXa) REFERENCES Xa(MaXa) ON DELETE CASCADE
);
GO

-- 8. KhachHang
CREATE TABLE KhachHang (
    MaKH VARCHAR(20) PRIMARY KEY,
    TenKH NVARCHAR(50) NOT NULL,
    DienThoaiKH VARCHAR(15) NOT NULL,
    EmailKH NVARCHAR(255),
    DiaChiKH NVARCHAR(255) NOT NULL,
    AnhKH NVARCHAR(255) NULL,
    MaXa SMALLINT NOT NULL,
    CONSTRAINT FK_KhachHang_Xa FOREIGN KEY (MaXa) REFERENCES Xa(MaXa) ON DELETE CASCADE
);
GO

-- 9. LoaiSP
CREATE TABLE LoaiSP (
    MaLoai VARCHAR(10) PRIMARY KEY, 
    TenLoai NVARCHAR(50) NOT NULL,
    MaNSP VARCHAR(10) NOT NULL,
    CONSTRAINT FK_LoaiSP_NhomSP FOREIGN KEY (MaNSP) REFERENCES NhomSP(MaNSP) ON DELETE CASCADE
);
GO

-- 10. SanPham
CREATE TABLE SanPham (
    MaSP VARCHAR(20) PRIMARY KEY,
    TenSP NVARCHAR(50) NOT NULL,
    GiaBan DECIMAL(18,2) NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL CHECK (TrangThai IN (N'Còn Hàng', N'Hết Hàng', N'Cháy Hàng', N'Sắp Hết')),
    SoLuongTon INT NOT NULL,
    AnhSP NVARCHAR(255) NULL,
    MaLoai VARCHAR(10) NOT NULL,
    MaNCC VARCHAR(20) NOT NULL,
    MaHSX VARCHAR(10) NOT NULL,
    CONSTRAINT FK_SanPham_LoaiSP FOREIGN KEY (MaLoai) REFERENCES LoaiSP(MaLoai) ON DELETE CASCADE,
    CONSTRAINT FK_SanPham_NhaCC FOREIGN KEY (MaNCC) REFERENCES NhaCC(MaNCC) ON DELETE CASCADE,
    CONSTRAINT FK_SanPham_HangSX FOREIGN KEY (MaHSX) REFERENCES HangSX(MaHSX) ON DELETE CASCADE
);
GO

-- 11. DonMuaHang
CREATE TABLE DonMuaHang (
    MaDMH VARCHAR(20) PRIMARY KEY,
    NgayMH DATE NOT NULL,
    MaNCC VARCHAR(20) NOT NULL,
    MaNV VARCHAR(20) NOT NULL,
    CONSTRAINT FK_DonMuaHang_NhaCC FOREIGN KEY (MaNCC) REFERENCES NhaCC(MaNCC) ON DELETE CASCADE,
    CONSTRAINT FK_DonMuaHang_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV) ON DELETE CASCADE
);
GO

-- 12. DonBanHang
CREATE TABLE DonBanHang (
    MaDBH VARCHAR(20) PRIMARY KEY,
    NgayBH DATE NOT NULL,
    MaKH VARCHAR(20) NOT NULL,
    CONSTRAINT FK_DonBanHang_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH) ON DELETE CASCADE
);
GO

-- 13. CTMH
CREATE TABLE CTMH (
    MaDMH VARCHAR(20) NOT NULL,
    MaSP VARCHAR(20) NOT NULL,
    SLM INT NOT NULL CHECK(SLM > 0),
    DGM DECIMAL(18,2) NOT NULL CHECK(DGM >= 0),
    CONSTRAINT PK_CTMH PRIMARY KEY(MaDMH, MaSP),
    CONSTRAINT FK_CTMH_DonMuaHang FOREIGN KEY (MaDMH) REFERENCES DonMuaHang(MaDMH) ON DELETE CASCADE,
    CONSTRAINT FK_CTMH_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP) 
);
GO

-- 14. CTBH
CREATE TABLE CTBH (
    MaDBH VARCHAR(20) NOT NULL,
    MaSP VARCHAR(20) NOT NULL,
    SLB INT NOT NULL CHECK(SLB > 0),
    DGB DECIMAL(18,2) NOT NULL CHECK(DGB >= 0),
    CONSTRAINT PK_CTBH PRIMARY KEY(MaDBH, MaSP),
    CONSTRAINT FK_CTBH_DonBanHang FOREIGN KEY (MaDBH) REFERENCES DonBanHang(MaDBH) ON DELETE CASCADE,
    CONSTRAINT FK_CTBH_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- ================================================================
-- PHẦN 2: STORED PROCEDURES (ĐÃ TÁCH DÒNG GO CHUẨN)
-- ================================================================

---------------------------------------------------------
-- 1. NUOC
---------------------------------------------------------
IF OBJECT_ID('dbo.Nuoc_GetAll') IS NOT NULL DROP PROC dbo.Nuoc_GetAll;
GO
CREATE PROC dbo.Nuoc_GetAll AS SELECT * FROM Nuoc;
GO

IF OBJECT_ID('dbo.Nuoc_GetById') IS NOT NULL DROP PROC dbo.Nuoc_GetById;
GO
CREATE PROC dbo.Nuoc_GetById @MaNuoc VARCHAR(10) AS SELECT * FROM Nuoc WHERE MaNuoc = @MaNuoc;
GO

IF OBJECT_ID('dbo.Nuoc_Insert') IS NOT NULL DROP PROC dbo.Nuoc_Insert;
GO
CREATE PROC dbo.Nuoc_Insert @MaNuoc VARCHAR(10), @TenNuoc NVARCHAR(50) AS INSERT INTO Nuoc VALUES(@MaNuoc, @TenNuoc);
GO

IF OBJECT_ID('dbo.Nuoc_Update') IS NOT NULL DROP PROC dbo.Nuoc_Update;
GO
CREATE PROC dbo.Nuoc_Update @MaNuoc VARCHAR(10), @TenNuoc NVARCHAR(50) AS UPDATE Nuoc SET TenNuoc=@TenNuoc WHERE MaNuoc=@MaNuoc;
GO

IF OBJECT_ID('dbo.Nuoc_Delete') IS NOT NULL DROP PROC dbo.Nuoc_Delete;
GO
CREATE PROC dbo.Nuoc_Delete @MaNuoc VARCHAR(10) AS DELETE FROM Nuoc WHERE MaNuoc=@MaNuoc;
GO

---------------------------------------------------------
-- 2. NHOMSP
---------------------------------------------------------
IF OBJECT_ID('dbo.NhomSP_GetAll') IS NOT NULL DROP PROC dbo.NhomSP_GetAll;
GO
CREATE PROC dbo.NhomSP_GetAll AS SELECT * FROM NhomSP;
GO

IF OBJECT_ID('dbo.NhomSP_GetById') IS NOT NULL DROP PROC dbo.NhomSP_GetById;
GO
CREATE PROC dbo.NhomSP_GetById @MaNSP VARCHAR(10) AS SELECT * FROM NhomSP WHERE MaNSP = @MaNSP;
GO

IF OBJECT_ID('dbo.NhomSP_Insert') IS NOT NULL DROP PROC dbo.NhomSP_Insert;
GO
CREATE PROC dbo.NhomSP_Insert @MaNSP VARCHAR(10), @TenNSP NVARCHAR(50) AS INSERT INTO NhomSP VALUES(@MaNSP, @TenNSP);
GO

IF OBJECT_ID('dbo.NhomSP_Update') IS NOT NULL DROP PROC dbo.NhomSP_Update;
GO
CREATE PROC dbo.NhomSP_Update @MaNSP VARCHAR(10), @TenNSP NVARCHAR(50) AS UPDATE NhomSP SET TenNSP=@TenNSP WHERE MaNSP=@MaNSP;
GO

IF OBJECT_ID('dbo.NhomSP_Delete') IS NOT NULL DROP PROC dbo.NhomSP_Delete;
GO
CREATE PROC dbo.NhomSP_Delete @MaNSP VARCHAR(10) AS DELETE FROM NhomSP WHERE MaNSP=@MaNSP;
GO

---------------------------------------------------------
-- 3. HANGSX
---------------------------------------------------------
IF OBJECT_ID('dbo.HangSX_GetAll') IS NOT NULL DROP PROC dbo.HangSX_GetAll;
GO
CREATE PROC dbo.HangSX_GetAll AS SELECT h.*, n.TenNuoc FROM HangSX h JOIN Nuoc n ON h.MaNuoc = n.MaNuoc;
GO

IF OBJECT_ID('dbo.HangSX_GetById') IS NOT NULL DROP PROC dbo.HangSX_GetById;
GO
CREATE PROC dbo.HangSX_GetById @MaHSX VARCHAR(10) AS SELECT h.*, n.TenNuoc FROM HangSX h JOIN Nuoc n ON h.MaNuoc = n.MaNuoc WHERE MaHSX=@MaHSX;
GO

IF OBJECT_ID('dbo.HangSX_Insert') IS NOT NULL DROP PROC dbo.HangSX_Insert;
GO
CREATE PROC dbo.HangSX_Insert @MaHSX VARCHAR(10), @TenHSX NVARCHAR(50), @MaNuoc VARCHAR(10) AS INSERT INTO HangSX VALUES(@MaHSX, @TenHSX, @MaNuoc);
GO

IF OBJECT_ID('dbo.HangSX_Update') IS NOT NULL DROP PROC dbo.HangSX_Update;
GO
CREATE PROC dbo.HangSX_Update @MaHSX VARCHAR(10), @TenHSX NVARCHAR(50), @MaNuoc VARCHAR(10) AS UPDATE HangSX SET TenHSX=@TenHSX, MaNuoc=@MaNuoc WHERE MaHSX=@MaHSX;
GO

IF OBJECT_ID('dbo.HangSX_Delete') IS NOT NULL DROP PROC dbo.HangSX_Delete;
GO
CREATE PROC dbo.HangSX_Delete @MaHSX VARCHAR(10) AS DELETE FROM HangSX WHERE MaHSX=@MaHSX;
GO

---------------------------------------------------------
-- 4. TINH
---------------------------------------------------------
IF OBJECT_ID('dbo.Tinh_GetAll') IS NOT NULL DROP PROC dbo.Tinh_GetAll;
GO
CREATE PROC dbo.Tinh_GetAll AS SELECT * FROM Tinh;
GO

IF OBJECT_ID('dbo.Tinh_GetById') IS NOT NULL DROP PROC dbo.Tinh_GetById;
GO
CREATE PROC dbo.Tinh_GetById @MaTinh SMALLINT AS SELECT * FROM Tinh WHERE MaTinh = @MaTinh;
GO

IF OBJECT_ID('dbo.Tinh_Insert') IS NOT NULL DROP PROC dbo.Tinh_Insert;
GO
CREATE PROC dbo.Tinh_Insert @TenTinh NVARCHAR(50) AS INSERT INTO Tinh(TenTinh) VALUES (@TenTinh);
GO

IF OBJECT_ID('dbo.Tinh_Update') IS NOT NULL DROP PROC dbo.Tinh_Update;
GO
CREATE PROC dbo.Tinh_Update @MaTinh SMALLINT, @TenTinh NVARCHAR(50) AS UPDATE Tinh SET TenTinh = @TenTinh WHERE MaTinh = @MaTinh;
GO

IF OBJECT_ID('dbo.Tinh_Delete') IS NOT NULL DROP PROC dbo.Tinh_Delete;
GO
CREATE PROC dbo.Tinh_Delete @MaTinh SMALLINT AS DELETE FROM Tinh WHERE MaTinh = @MaTinh;
GO

---------------------------------------------------------
-- 5. XA
---------------------------------------------------------
IF OBJECT_ID('dbo.Xa_GetAll') IS NOT NULL DROP PROC dbo.Xa_GetAll;
GO
CREATE PROC dbo.Xa_GetAll AS SELECT x.*, t.TenTinh FROM Xa x JOIN Tinh t ON x.MaTinh = t.MaTinh;
GO

IF OBJECT_ID('dbo.Xa_GetById') IS NOT NULL DROP PROC dbo.Xa_GetById;
GO
CREATE PROC dbo.Xa_GetById @MaXa SMALLINT AS SELECT x.*, t.TenTinh FROM Xa x JOIN Tinh t ON x.MaTinh = t.MaTinh WHERE x.MaXa = @MaXa;
GO

IF OBJECT_ID('dbo.Xa_Insert') IS NOT NULL DROP PROC dbo.Xa_Insert;
GO
CREATE PROC dbo.Xa_Insert @TenXa NVARCHAR(50), @MaTinh SMALLINT AS INSERT INTO Xa(TenXa, MaTinh) VALUES (@TenXa, @MaTinh);
GO

IF OBJECT_ID('dbo.Xa_Update') IS NOT NULL DROP PROC dbo.Xa_Update;
GO
CREATE PROC dbo.Xa_Update @MaXa SMALLINT, @TenXa NVARCHAR(50), @MaTinh SMALLINT AS UPDATE Xa SET TenXa = @TenXa, MaTinh = @MaTinh WHERE MaXa = @MaXa;
GO

IF OBJECT_ID('dbo.Xa_Delete') IS NOT NULL DROP PROC dbo.Xa_Delete;
GO
CREATE PROC dbo.Xa_Delete @MaXa SMALLINT AS DELETE FROM Xa WHERE MaXa = @MaXa;
GO

---------------------------------------------------------
-- 6. NHANVIEN
---------------------------------------------------------
IF OBJECT_ID('dbo.NhanVien_GetAll') IS NOT NULL DROP PROC dbo.NhanVien_GetAll;
GO
CREATE PROC dbo.NhanVien_GetAll @Search NVARCHAR(50) = NULL 
AS SELECT * FROM NhanVien WHERE (@Search IS NULL OR TenNV LIKE '%' + @Search + '%');
GO

IF OBJECT_ID('dbo.NhanVien_GetById') IS NOT NULL DROP PROC dbo.NhanVien_GetById;
GO
CREATE PROC dbo.NhanVien_GetById @MaNV VARCHAR(20) AS SELECT * FROM NhanVien WHERE MaNV=@MaNV;
GO

IF OBJECT_ID('dbo.NhanVien_Insert') IS NOT NULL DROP PROC dbo.NhanVien_Insert;
GO
CREATE PROC dbo.NhanVien_Insert @TenNV NVARCHAR(50), @MatKhau VARCHAR(50), @DienThoaiNV VARCHAR(15), @DiaChiNV NVARCHAR(255)
AS BEGIN
    DECLARE @prefix VARCHAR(8) = 'NV' + FORMAT(GETDATE(), 'yyMMdd');
    DECLARE @id INT;
    SELECT @id = ISNULL(MAX(CAST(RIGHT(MaNV, 4) AS INT)), 0) + 1 FROM NhanVien WHERE LEFT(MaNV, 8) = @prefix;
    DECLARE @MaNV VARCHAR(20) = @prefix + RIGHT('0000' + CAST(@id AS VARCHAR(4)), 4);
    INSERT INTO NhanVien VALUES(@MaNV, @TenNV, @MatKhau, @DienThoaiNV, @DiaChiNV);
    SELECT @MaNV;
END
GO

IF OBJECT_ID('dbo.NhanVien_Update') IS NOT NULL DROP PROC dbo.NhanVien_Update;
GO
CREATE PROC dbo.NhanVien_Update @MaNV VARCHAR(20), @TenNV NVARCHAR(50), @MatKhau VARCHAR(50), @DienThoaiNV VARCHAR(15), @DiaChiNV NVARCHAR(255)
AS UPDATE NhanVien SET TenNV=@TenNV, MatKhau=@MatKhau, DienThoaiNV=@DienThoaiNV, DiaChiNV=@DiaChiNV WHERE MaNV=@MaNV;
GO

IF OBJECT_ID('dbo.NhanVien_Delete') IS NOT NULL DROP PROC dbo.NhanVien_Delete;
GO
CREATE PROC dbo.NhanVien_Delete @MaNV VARCHAR(20) AS DELETE FROM NhanVien WHERE MaNV=@MaNV;
GO

---------------------------------------------------------
-- 7. NHACC
---------------------------------------------------------
IF OBJECT_ID('dbo.NhaCC_GetAll') IS NOT NULL DROP PROC dbo.NhaCC_GetAll;
GO
CREATE PROC dbo.NhaCC_GetAll AS SELECT n.*, x.TenXa, t.TenTinh FROM NhaCC n JOIN Xa x ON n.MaXa = x.MaXa JOIN Tinh t ON x.MaTinh = t.MaTinh;
GO

IF OBJECT_ID('dbo.NhaCC_GetById') IS NOT NULL DROP PROC dbo.NhaCC_GetById;
GO
CREATE PROC dbo.NhaCC_GetById @MaNCC VARCHAR(20) AS SELECT n.*, x.TenXa, t.TenTinh FROM NhaCC n JOIN Xa x ON n.MaXa = x.MaXa JOIN Tinh t ON x.MaTinh = t.MaTinh WHERE MaNCC = @MaNCC;
GO

IF OBJECT_ID('dbo.NhaCC_Insert') IS NOT NULL DROP PROC dbo.NhaCC_Insert;
GO
CREATE PROC dbo.NhaCC_Insert @TenNCC NVARCHAR(100), @DienThoaiNCC VARCHAR(15), @EmailNCC VARCHAR(100), @DiaChiNCC NVARCHAR(255), @MaXa SMALLINT
AS BEGIN
    DECLARE @prefix VARCHAR(8) = 'NC' + FORMAT(GETDATE(), 'yyMMdd');
    DECLARE @id INT;
    SELECT @id = ISNULL(MAX(CAST(RIGHT(MaNCC, 4) AS INT)), 0) + 1 FROM NhaCC WHERE LEFT(MaNCC, 8) = @prefix;
    DECLARE @MaNCC VARCHAR(20) = @prefix + RIGHT('0000' + CAST(@id AS VARCHAR(4)), 4);
    INSERT INTO NhaCC VALUES (@MaNCC, @TenNCC, @DienThoaiNCC, @EmailNCC, @DiaChiNCC, @MaXa);
    SELECT @MaNCC;
END
GO

IF OBJECT_ID('dbo.NhaCC_Update') IS NOT NULL DROP PROC dbo.NhaCC_Update;
GO
CREATE PROC dbo.NhaCC_Update @MaNCC VARCHAR(20), @TenNCC NVARCHAR(100), @DienThoaiNCC VARCHAR(15), @EmailNCC VARCHAR(100), @DiaChiNCC NVARCHAR(255), @MaXa SMALLINT
AS UPDATE NhaCC SET TenNCC=@TenNCC, DienThoaiNCC=@DienThoaiNCC, EmailNCC=@EmailNCC, DiaChiNCC=@DiaChiNCC, MaXa=@MaXa WHERE MaNCC=@MaNCC;
GO

IF OBJECT_ID('dbo.NhaCC_Delete') IS NOT NULL DROP PROC dbo.NhaCC_Delete;
GO
CREATE PROC dbo.NhaCC_Delete @MaNCC VARCHAR(20) AS DELETE FROM NhaCC WHERE MaNCC = @MaNCC;
GO

---------------------------------------------------------
-- 8. KHACHHANG
---------------------------------------------------------
IF OBJECT_ID('dbo.KhachHang_GetAll') IS NOT NULL DROP PROC dbo.KhachHang_GetAll;
GO
CREATE PROC dbo.KhachHang_GetAll @Search NVARCHAR(200) = NULL
AS SELECT k.*, x.TenXa, t.TenTinh FROM KhachHang k JOIN Xa x ON k.MaXa = x.MaXa JOIN Tinh t ON x.MaTinh = t.MaTinh WHERE (@Search IS NULL OR k.TenKH LIKE '%' + @Search + '%');
GO

IF OBJECT_ID('dbo.KhachHang_GetById') IS NOT NULL DROP PROC dbo.KhachHang_GetById;
GO
CREATE PROC dbo.KhachHang_GetById @MaKH VARCHAR(20) AS SELECT k.*, x.TenXa, t.TenTinh FROM KhachHang k JOIN Xa x ON k.MaXa = x.MaXa JOIN Tinh t ON x.MaTinh = t.MaTinh WHERE MaKH = @MaKH;
GO

IF OBJECT_ID('dbo.KhachHang_Insert') IS NOT NULL DROP PROC dbo.KhachHang_Insert;
GO
CREATE PROC dbo.KhachHang_Insert @TenKH NVARCHAR(50), @DienThoaiKH VARCHAR(15), @EmailKH NVARCHAR(255), @DiaChiKH NVARCHAR(255), @AnhKH NVARCHAR(255), @MaXa SMALLINT
AS BEGIN
    DECLARE @prefix VARCHAR(8) = 'KH' + FORMAT(GETDATE(), 'yyMMdd');
    DECLARE @id INT;
    SELECT @id = ISNULL(MAX(CAST(RIGHT(MaKH, 4) AS INT)), 0) + 1 FROM KhachHang WHERE LEFT(MaKH, 8) = @prefix;
    DECLARE @MaKH VARCHAR(20) = @prefix + RIGHT('0000' + CAST(@id AS VARCHAR(4)), 4);
    INSERT INTO KhachHang VALUES (@MaKH, @TenKH, @DienThoaiKH, @EmailKH, @DiaChiKH, @AnhKH, @MaXa);
    SELECT @MaKH;
END
GO

IF OBJECT_ID('dbo.KhachHang_Update') IS NOT NULL DROP PROC dbo.KhachHang_Update;
GO
CREATE PROC dbo.KhachHang_Update @MaKH VARCHAR(20), @TenKH NVARCHAR(50), @DienThoaiKH VARCHAR(15), @EmailKH NVARCHAR(255), @DiaChiKH NVARCHAR(255), @AnhKH NVARCHAR(255), @MaXa SMALLINT
AS BEGIN
    IF @AnhKH IS NULL OR @AnhKH = ''
        UPDATE KhachHang SET TenKH=@TenKH, DienThoaiKH=@DienThoaiKH, EmailKH=@EmailKH, DiaChiKH=@DiaChiKH, MaXa=@MaXa WHERE MaKH=@MaKH;
    ELSE
        UPDATE KhachHang SET TenKH=@TenKH, DienThoaiKH=@DienThoaiKH, EmailKH=@EmailKH, DiaChiKH=@DiaChiKH, AnhKH=@AnhKH, MaXa=@MaXa WHERE MaKH=@MaKH;
END
GO

IF OBJECT_ID('dbo.KhachHang_Delete') IS NOT NULL DROP PROC dbo.KhachHang_Delete;
GO
CREATE PROC dbo.KhachHang_Delete @MaKH VARCHAR(20) AS DELETE FROM KhachHang WHERE MaKH = @MaKH;
GO

---------------------------------------------------------
-- 9. LOAISP
---------------------------------------------------------
IF OBJECT_ID('dbo.LoaiSP_GetAll') IS NOT NULL DROP PROC dbo.LoaiSP_GetAll;
GO
CREATE PROC dbo.LoaiSP_GetAll AS SELECT l.*, n.TenNSP FROM LoaiSP l JOIN NhomSP n ON l.MaNSP = n.MaNSP;
GO

IF OBJECT_ID('dbo.LoaiSP_GetById') IS NOT NULL DROP PROC dbo.LoaiSP_GetById;
GO
CREATE PROC dbo.LoaiSP_GetById @MaLoai VARCHAR(10) AS SELECT l.*, n.TenNSP FROM LoaiSP l JOIN NhomSP n ON l.MaNSP = n.MaNSP WHERE MaLoai = @MaLoai;
GO

IF OBJECT_ID('dbo.LoaiSP_Insert') IS NOT NULL DROP PROC dbo.LoaiSP_Insert;
GO
CREATE PROC dbo.LoaiSP_Insert @MaLoai VARCHAR(10), @TenLoai NVARCHAR(50), @MaNSP VARCHAR(10) AS INSERT INTO LoaiSP VALUES (@MaLoai, @TenLoai, @MaNSP);
GO

IF OBJECT_ID('dbo.LoaiSP_Update') IS NOT NULL DROP PROC dbo.LoaiSP_Update;
GO
CREATE PROC dbo.LoaiSP_Update @MaLoai VARCHAR(10), @TenLoai NVARCHAR(50), @MaNSP VARCHAR(10) AS UPDATE LoaiSP SET TenLoai=@TenLoai, MaNSP=@MaNSP WHERE MaLoai=@MaLoai;
GO

IF OBJECT_ID('dbo.LoaiSP_Delete') IS NOT NULL DROP PROC dbo.LoaiSP_Delete;
GO
CREATE PROC dbo.LoaiSP_Delete @MaLoai VARCHAR(10) AS DELETE FROM LoaiSP WHERE MaLoai = @MaLoai;
GO

---------------------------------------------------------
-- 10. SANPHAM
---------------------------------------------------------
IF OBJECT_ID('dbo.SanPham_GetAll') IS NOT NULL DROP PROC dbo.SanPham_GetAll;
GO
CREATE PROC dbo.SanPham_GetAll @Search NVARCHAR(50) = NULL
AS SELECT s.*, l.TenLoai, n.TenNCC, h.TenHSX
FROM SanPham s 
JOIN LoaiSP l ON s.MaLoai = l.MaLoai 
JOIN NhaCC n ON s.MaNCC = n.MaNCC
JOIN HangSX h ON s.MaHSX = h.MaHSX
WHERE (@Search IS NULL OR s.TenSP LIKE '%' + @Search + '%');
GO

IF OBJECT_ID('dbo.SanPham_GetById') IS NOT NULL DROP PROC dbo.SanPham_GetById;
GO
CREATE PROC dbo.SanPham_GetById @MaSP VARCHAR(20) 
AS SELECT s.*, l.TenLoai, n.TenNCC, h.TenHSX 
FROM SanPham s 
JOIN LoaiSP l ON s.MaLoai = l.MaLoai 
JOIN NhaCC n ON s.MaNCC = n.MaNCC 
JOIN HangSX h ON s.MaHSX = h.MaHSX
WHERE s.MaSP = @MaSP;
GO

IF OBJECT_ID('dbo.SanPham_Insert') IS NOT NULL DROP PROC dbo.SanPham_Insert;
GO
CREATE PROC dbo.SanPham_Insert @TenSP NVARCHAR(50), @GiaBan DECIMAL(18,2), @TrangThai NVARCHAR(50), @SoLuongTon INT, @AnhSP NVARCHAR(255), @MaLoai VARCHAR(10), @MaNCC VARCHAR(20), @MaHSX VARCHAR(10)
AS BEGIN
    DECLARE @prefix VARCHAR(8) = 'SP' + FORMAT(GETDATE(), 'yyMMdd');
    DECLARE @id INT;
    SELECT @id = ISNULL(MAX(CAST(RIGHT(MaSP, 4) AS INT)), 0) + 1 FROM SanPham WHERE LEFT(MaSP, 8) = @prefix;
    DECLARE @MaSP VARCHAR(20) = @prefix + RIGHT('0000' + CAST(@id AS VARCHAR(4)), 4);
    INSERT INTO SanPham VALUES (@MaSP, @TenSP, @GiaBan, @TrangThai, @SoLuongTon, @AnhSP, @MaLoai, @MaNCC, @MaHSX);
    SELECT @MaSP;
END
GO

IF OBJECT_ID('dbo.SanPham_Update') IS NOT NULL DROP PROC dbo.SanPham_Update;
GO
CREATE PROC dbo.SanPham_Update @MaSP VARCHAR(20), @TenSP NVARCHAR(50), @GiaBan DECIMAL(18,2), @TrangThai NVARCHAR(50), @SoLuongTon INT, @AnhSP NVARCHAR(255), @MaLoai VARCHAR(10), @MaNCC VARCHAR(20), @MaHSX VARCHAR(10)
AS BEGIN
    IF @AnhSP IS NULL OR @AnhSP = ''
        UPDATE SanPham SET TenSP=@TenSP, GiaBan=@GiaBan, TrangThai=@TrangThai, SoLuongTon=@SoLuongTon, MaLoai=@MaLoai, MaNCC=@MaNCC, MaHSX=@MaHSX WHERE MaSP=@MaSP;
    ELSE
        UPDATE SanPham SET TenSP=@TenSP, GiaBan=@GiaBan, TrangThai=@TrangThai, SoLuongTon=@SoLuongTon, AnhSP=@AnhSP, MaLoai=@MaLoai, MaNCC=@MaNCC, MaHSX=@MaHSX WHERE MaSP=@MaSP;
END
GO

IF OBJECT_ID('dbo.SanPham_Delete') IS NOT NULL DROP PROC dbo.SanPham_Delete;
GO
CREATE PROC dbo.SanPham_Delete @MaSP VARCHAR(20) AS DELETE FROM SanPham WHERE MaSP = @MaSP;
GO

---------------------------------------------------------
-- 11. DONBANHANG
---------------------------------------------------------
IF OBJECT_ID('dbo.DonBanHang_GetAll') IS NOT NULL DROP PROC dbo.DonBanHang_GetAll;
GO
CREATE PROC dbo.DonBanHang_GetAll AS SELECT d.*, k.TenKH FROM DonBanHang d JOIN KhachHang k ON d.MaKH = k.MaKH;
GO

IF OBJECT_ID('dbo.DonBanHang_GetById') IS NOT NULL DROP PROC dbo.DonBanHang_GetById;
GO
CREATE PROC dbo.DonBanHang_GetById @MaDBH VARCHAR(20) AS SELECT d.*, k.TenKH FROM DonBanHang d JOIN KhachHang k ON d.MaKH = k.MaKH WHERE d.MaDBH = @MaDBH;
GO

IF OBJECT_ID('dbo.DonBanHang_Insert') IS NOT NULL DROP PROC dbo.DonBanHang_Insert;
GO
CREATE PROC dbo.DonBanHang_Insert @MaKH VARCHAR(20)
AS BEGIN
    DECLARE @prefix VARCHAR(8) = 'BH' + FORMAT(GETDATE(), 'yyMMdd');
    DECLARE @id INT;
    SELECT @id = ISNULL(MAX(CAST(RIGHT(MaDBH, 4) AS INT)), 0) + 1 FROM DonBanHang WHERE LEFT(MaDBH, 8) = @prefix;
    DECLARE @MaDBH VARCHAR(20) = @prefix + RIGHT('0000' + CAST(@id AS VARCHAR(4)), 4);
    INSERT INTO DonBanHang VALUES (@MaDBH, GETDATE(), @MaKH);
    SELECT @MaDBH;
END
GO

IF OBJECT_ID('dbo.DonBanHang_Update') IS NOT NULL DROP PROC dbo.DonBanHang_Update;
GO
CREATE PROC dbo.DonBanHang_Update @MaDBH VARCHAR(20), @NgayBH DATE, @MaKH VARCHAR(20) AS UPDATE DonBanHang SET NgayBH=@NgayBH, MaKH=@MaKH WHERE MaDBH=@MaDBH;
GO

IF OBJECT_ID('dbo.DonBanHang_Delete') IS NOT NULL DROP PROC dbo.DonBanHang_Delete;
GO
CREATE PROC dbo.DonBanHang_Delete @MaDBH VARCHAR(20) AS DELETE FROM DonBanHang WHERE MaDBH=@MaDBH;
GO

---------------------------------------------------------
-- 12. DONMUAHANG
---------------------------------------------------------
IF OBJECT_ID('dbo.DonMuaHang_GetAll') IS NOT NULL DROP PROC dbo.DonMuaHang_GetAll;
GO
CREATE PROC dbo.DonMuaHang_GetAll AS SELECT d.*, n.TenNCC, nv.TenNV FROM DonMuaHang d JOIN NhaCC n ON d.MaNCC = n.MaNCC JOIN NhanVien nv ON d.MaNV = nv.MaNV;
GO

IF OBJECT_ID('dbo.DonMuaHang_GetById') IS NOT NULL DROP PROC dbo.DonMuaHang_GetById;
GO
CREATE PROC dbo.DonMuaHang_GetById @MaDMH VARCHAR(20) AS SELECT d.*, n.TenNCC, nv.TenNV FROM DonMuaHang d JOIN NhaCC n ON d.MaNCC = n.MaNCC JOIN NhanVien nv ON d.MaNV = nv.MaNV WHERE MaDMH = @MaDMH;
GO

IF OBJECT_ID('dbo.DonMuaHang_Insert') IS NOT NULL DROP PROC dbo.DonMuaHang_Insert;
GO
CREATE PROC dbo.DonMuaHang_Insert @MaNCC VARCHAR(20), @MaNV VARCHAR(20)
AS BEGIN
    DECLARE @prefix VARCHAR(8) = 'MH' + FORMAT(GETDATE(), 'yyMMdd');
    DECLARE @id INT;
    SELECT @id = ISNULL(MAX(CAST(RIGHT(MaDMH, 4) AS INT)), 0) + 1 FROM DonMuaHang WHERE LEFT(MaDMH, 8) = @prefix;
    DECLARE @MaDMH VARCHAR(20) = @prefix + RIGHT('0000' + CAST(@id AS VARCHAR(4)), 4);
    INSERT INTO DonMuaHang VALUES (@MaDMH, GETDATE(), @MaNCC, @MaNV);
    SELECT @MaDMH;
END
GO

IF OBJECT_ID('dbo.DonMuaHang_Update') IS NOT NULL DROP PROC dbo.DonMuaHang_Update;
GO
CREATE PROC dbo.DonMuaHang_Update @MaDMH VARCHAR(20), @NgayMH DATE, @MaNCC VARCHAR(20), @MaNV VARCHAR(20) AS UPDATE DonMuaHang SET NgayMH=@NgayMH, MaNCC=@MaNCC, MaNV=@MaNV WHERE MaDMH=@MaDMH;
GO

IF OBJECT_ID('dbo.DonMuaHang_Delete') IS NOT NULL DROP PROC dbo.DonMuaHang_Delete;
GO
CREATE PROC dbo.DonMuaHang_Delete @MaDMH VARCHAR(20) AS DELETE FROM DonMuaHang WHERE MaDMH=@MaDMH;
GO

---------------------------------------------------------
-- 13 & 14. CHI TIẾT ĐƠN
---------------------------------------------------------
IF OBJECT_ID('dbo.CTMH_GetByDonHang') IS NOT NULL DROP PROC dbo.CTMH_GetByDonHang;
GO
CREATE PROC dbo.CTMH_GetByDonHang @MaDMH VARCHAR(20) AS SELECT c.*, s.TenSP FROM CTMH c JOIN SanPham s ON c.MaSP = s.MaSP WHERE c.MaDMH = @MaDMH;
GO

IF OBJECT_ID('dbo.CTMH_GetOne') IS NOT NULL DROP PROC dbo.CTMH_GetOne;
GO
CREATE PROC dbo.CTMH_GetOne @MaDMH VARCHAR(20), @MaSP VARCHAR(20) AS SELECT * FROM CTMH WHERE MaDMH = @MaDMH AND MaSP = @MaSP;
GO

IF OBJECT_ID('dbo.CTMH_Insert') IS NOT NULL DROP PROC dbo.CTMH_Insert;
GO
CREATE PROC dbo.CTMH_Insert @MaDMH VARCHAR(20), @MaSP VARCHAR(20), @SLM INT, @DGM DECIMAL(18,2) AS INSERT INTO CTMH VALUES (@MaDMH, @MaSP, @SLM, @DGM);
GO

IF OBJECT_ID('dbo.CTMH_Update') IS NOT NULL DROP PROC dbo.CTMH_Update;
GO
CREATE PROC dbo.CTMH_Update @MaDMH VARCHAR(20), @MaSP VARCHAR(20), @SLM INT, @DGM DECIMAL(18,2) AS UPDATE CTMH SET SLM=@SLM, DGM=@DGM WHERE MaDMH=@MaDMH AND MaSP=@MaSP;
GO

IF OBJECT_ID('dbo.CTMH_Delete') IS NOT NULL DROP PROC dbo.CTMH_Delete;
GO
CREATE PROC dbo.CTMH_Delete @MaDMH VARCHAR(20), @MaSP VARCHAR(20) AS DELETE FROM CTMH WHERE MaDMH=@MaDMH AND MaSP=@MaSP;
GO

IF OBJECT_ID('dbo.CTBH_GetByDonHang') IS NOT NULL DROP PROC dbo.CTBH_GetByDonHang;
GO
CREATE PROC dbo.CTBH_GetByDonHang @MaDBH VARCHAR(20) AS SELECT c.*, s.TenSP FROM CTBH c JOIN SanPham s ON c.MaSP = s.MaSP WHERE c.MaDBH = @MaDBH;
GO

IF OBJECT_ID('dbo.CTBH_GetOne') IS NOT NULL DROP PROC dbo.CTBH_GetOne;
GO
CREATE PROC dbo.CTBH_GetOne @MaDBH VARCHAR(20), @MaSP VARCHAR(20) AS SELECT * FROM CTBH WHERE MaDBH = @MaDBH AND MaSP = @MaSP;
GO

IF OBJECT_ID('dbo.CTBH_Insert') IS NOT NULL DROP PROC dbo.CTBH_Insert;
GO
CREATE PROC dbo.CTBH_Insert @MaDBH VARCHAR(20), @MaSP VARCHAR(20), @SLB INT, @DGB DECIMAL(18,2) AS INSERT INTO CTBH VALUES (@MaDBH, @MaSP, @SLB, @DGB);
GO

IF OBJECT_ID('dbo.CTBH_Update') IS NOT NULL DROP PROC dbo.CTBH_Update;
GO
CREATE PROC dbo.CTBH_Update @MaDBH VARCHAR(20), @MaSP VARCHAR(20), @SLB INT, @DGB DECIMAL(18,2) AS UPDATE CTBH SET SLB=@SLB, DGB=@DGB WHERE MaDBH=@MaDBH AND MaSP=@MaSP;
GO

IF OBJECT_ID('dbo.CTBH_Delete') IS NOT NULL DROP PROC dbo.CTBH_Delete;
GO
CREATE PROC dbo.CTBH_Delete @MaDBH VARCHAR(20), @MaSP VARCHAR(20) AS DELETE FROM CTBH WHERE MaDBH=@MaDBH AND MaSP=@MaSP;
GO