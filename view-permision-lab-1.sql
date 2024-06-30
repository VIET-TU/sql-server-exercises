
-- Bài tập 1: Cho CSDL về quản lý sinh viên trong file QLSinhVien.sql như hình dưới

USE QLSV

-- 1. Tạo View danh sách sinh viên, gồm các thông tin sau: Mã sinh viên, Họ sinh viên,
-- Tên sinh viên, Học bổng.
CREATE VIEW DS_SV 
AS 
SELECT DSSinhVien.MaSV, DSSinhVien.HoSV,
DSSinhVien.TenSV,DSSinhVien.HocBong FROM DSSinhVien


SELECT * FROM DS_SV

DROP VIEW DS_SV

-- 2. Tạo view Liệt kê các sinh viên có học bổng từ 150,000 trở lên và sinh ở Hà Nội, gồm
--các thông tin: Họ tên sinh viên, Mã khoa, Nơi sinh, Học bổng.

CREATE VIEW DS_SVHN
AS 
SELECT DSSinhVien.HoSV + ' ' + DSSinhVien.TenSV as 'Ho va ten',
DSSinhVien.MaKhoa,
DSSinhVien.HocBong FROM DSSinhVien
WHERE DSSinhVien.HocBong >= 150000 AND DSSinhVien.NoiSinh = N'Hà Nội'

SELECT * FROM DS_SVHN

DROP VIEW DS_SVHN

-- 3. Tạo view liệt kê những sinh viên nam của khoa Anh văn và khoa tin học, gồm các thông
-- tin: Mã sinh viên, Họ tên sinh viên, tên khoa, Phái.

CREATE VIEW DS_SVNAM AS
SELECT DSSinhVien.MaSV, DSSinhVien.HoSV + ' ' + DSSinhVien.TenSV 
as 'Ho va ten',DMKhoa.TenKhoa, DSSinhVien.Phai   FROM DSSinhVien JOIN DMKhoa 
ON DSSinhVien.MaKhoa = DMKhoa.MaKhoa
WHERE DSSinhVien.Phai = 'NAM' AND 
(DMKhoa.TenKhoa = N'Anh Văn' OR DMKhoa.TenKhoa = N'Tin Học')

SELECT * FROM DS_SVNAM

DROP VIEW DS_SVNAM

-- 4. Tạo view gồm những sinh viên có tuổi từ 20 đến 25, thông tin gồm: Họ tên sinh viên,
-- Tuổi, Tên khoa.

CREATE VIEW DS_SVTUOI_20_DEN_25 AS
SELECT 
    DSSinhVien.HoSV + ' ' + DSSinhVien.TenSV AS 'Ho va ten',
   (DATEDIFF(YEAR, DSSinhVien.NgaySinh, GETDATE()) - 
        CASE 
            WHEN DATEPART(DAYOFYEAR, DSSinhVien.NgaySinh) > DATEPART(DAYOFYEAR, GETDATE()) 
            THEN 1 
            ELSE 0 
        END) AS Tuoi,
    DMKhoa.TenKhoa
FROM DSSinhVien JOIN DMKhoa 
ON DSSinhVien.MaKhoa = DMKhoa.MaKhoa
WHERE (DATEDIFF(YEAR, DSSinhVien.NgaySinh, GETDATE()) - 
        CASE 
            WHEN DATEPART(DAYOFYEAR, DSSinhVien.NgaySinh) > DATEPART(DAYOFYEAR, GETDATE()) 
            THEN 1 
            ELSE 0 
        END) BETWEEN 20 AND 25;


SELECT * FROM DS_SVTUOI_20_DEN_25

--5. Tạo view cho biết thông tin về mức học bổng của các sinh viên, gồm: Mã sinh viên,
-- Phái, Mã khoa, Mức học bổng. Trong đó, mức học bổng sẽ hiển thị là “Học bổng cao”
-- nếu giá trị của field học bổng lớn hơn 500,000 và ngược lại hiển thị là “Mức trung bình”

CREATE VIEW DS_MUCHOCBONG AS 
SELECT DSSinhVien.MaSV, DSSinhVien.Phai,DSSinhVien.MaKhoa, 
 CASE
        WHEN DSSinhVien.HocBong > 500000 THEN N'Học bổng cao'
        ELSE N'Mức trung bình'
    END AS MucHocBong
FROM DSSinhVien

SELECT * FROM DS_MUCHOCBONG

DROP VIEW DS_MUCHOCBONG

--  6. Tạo view đưa ra thông tin những sinh viên có học bổng lớn hơn bất kỳ học bổng của
-- sinh viên học khóa anh văn


CREATE VIEW DS_SVHOCBONG AS 
SELECT * FROM DSSinhVien 
WHERE DSSinhVien.HocBong > (
	SELECT MAX(DSSinhVien.HocBong) FROM DSSinhVien
	 JOIN DMKhoa ON DSSinhVien.MaKhoa = DMKhoa.MaKhoa
	 WHERE DMKhoa.TenKhoa = N'Anh văn' 
)

SELECT * FROM DS_SVHOCBONG

DROP VIEW DS_SVHOCBONG

-- 7. Tạo view đưa ra thông tin những sinh viên đạt điểm cao nhất trong từng môn.


SELECT *, DMMonHoc.TenMH,MaxDiemMH.MaxDiem  FROM DSSinhVien
join KetQua on KetQua.MaSV = DSSinhVien.MaSV
join (
	SELECT KetQua.MaMH , MAX(KetQua.Diem) AS MaxDiem
	FROM KetQua
	GROUP BY KetQua.MaMH
) as MaxDiemMH  ON MaxDiemMH.MaMH = KetQua.MaMH
join DMMonHoc on DMMonHoc.MaMH = MaxDiemMH.MaMH

CREATE VIEW DS_SVDATDIEMCAONHATTUNGMON AS
SELECT KetQua.MaSV, DSSinhVien.HoSV,DSSinhVien.TenSV,KetQua.MaMH, DMMonHoc.TenMH, KetQua.LanThi,
KetQua.Diem FROM KetQua 
JOIN (
    SELECT MaMH, MAX(Diem) AS MaxDiem
    FROM KetQua
    GROUP BY MaMH
) AS MaxDiemMH
ON KetQua.MaMH = MaxDiemMH.MaMH AND KetQua.Diem = MaxDiemMH.MaxDiem
 JOIN DSSinhVien  ON KetQua.MaSV = DSSinhVien.MaSV
 JOIN DMMonHoc  ON KetQua.MaMH = DMMonHoc.MaMH;

 SELECT * FROM DS_SVDATDIEMCAONHATTUNGMON

DROP VIEW DS_SVDATDIEMCAONHATTUNGMON



-- 8. Tạo view đưa ra những sinh viên chưa thi môn cơ sở dữ liệu.
CREATE VIEW DS_SVCHUATHIMONCSDL AS
SELECT *
FROM DSSinhVien WHERE  DSSinhVien.MaSV NOT IN  (
	SELECT KetQua.MaSV 
	FROM KetQua
	JOIN DMMonHoc ON KetQua.MaMH = DMMonHoc.MaMH
	WHERE DMMonHoC.TenMH = N'Cơ Sở Dữ Liệu'
) 

 SELECT * FROM DS_SVCHUATHIMONCSDL

DROP VIEW DS_SVCHUATHIMONCSDL

-- 9. Tạo view đưa ra thông tin những sinh viên không trượt môn nào.


CREATE VIEW DS_SVKOTRUOTMONNAO AS
SELECT *
FROM DSSinhVien 
WHERE DSSinhVien.MaSV NOT IN (
    SELECT KQ.MaSV
    FROM KetQua KQ
    WHERE KQ.Diem < 5.0
);


 SELECT * FROM DS_SVKOTRUOTMONNAO


-- Bài 2: Cho cơ sở dữ liệu về quản lý học sinh như sau (file QLHocSinh.sql):

USE [QLHocSinh]

-- 1. Tạo view DSHS10A1 gồm thông tin Mã học sinh, họ tên, giới tính (là “Nữ” nếu Nu=1,
-- ngược lại là “Nam”), các điểm Toán, Lý, Hóa, Văn của các học sinh lớp 10A1
create view DSHS10A1 AS 
SELECT DSHS.MAHS, DSHS.HO + ' ' + DSHS.TEN AS HoTen, IIF(DSHS.NU = 0, 'Nam',N'Nữ') AS GIOITINH,
DIEM.TOAN, DIEM.LY, DIEM.HOA FROM DSHS
JOIN DIEM ON DIEM.MAHS = DSHS.MAHS
WHERE DSHS.MALOP = N'10A1'

SELECT * FROM DSHS10A1

-- 2. Tạo login TranThanhPhong, tạo user TranThanhPhong cho TranThanhPhong trên CSDLQLHocSinh Phân quyền Select trên view DSHS10A1 cho TranThanhPhong Đăng nhập TranThanhPhong để kiểm tra Tạo login PhamVanNam, tạo PhamVanNam cho PhamVanNam trên CSDL QLHocSinh Đăng nhập PhamVanNam để kiểm tra Tạo view DSHS10A2 tương tự như câu 1 Phân quyền Select trên view DSHS10A2 cho PhamVanNam Đăng nhập PhamVanNam để kiểm tra

EXEC sp_addlogin TranThanhPhong, '123'
use  [QLHocSinh] 
EXEC sp_adduser TranThanhPhong, TranThanhPhong

GRANT SELECT ON DSHS10A1  to TranThanhPhong


EXEC sp_addlogin PhamVanNam, '123'
use  [QLHocSinh] 
EXEC sp_adduser PhamVanNam, PhamVanNam

create view DSHS10A2 AS 
SELECT DSHS.MAHS, DSHS.HO + ' ' + DSHS.TEN AS HoTen, IIF(DSHS.NU = 0, 'Nam',N'Nữ') AS GIOITINH,
DIEM.TOAN, DIEM.LY, DIEM.HOA FROM DSHS
JOIN DIEM ON DIEM.MAHS = DSHS.MAHS
WHERE DSHS.MALOP = N'10A2'

select * from DSHS10A2


GRANT SELECT ON DSHS10A2  to PhamVanNam




-- 3. Tạo view báo cáo Kết thúc năm học gồm các thông tin: Mã học sinh, Họ và tên, Ngày sinh, Giới tính, Điểm Toán, Lý, Hóa, Văn, Điểm Trung bình, Xếp loại, Sắp xếp theo xếp loại (chọn 1000 bản ghi đầu). Trong đó: Điểm trung bình (DTB) = ((Toán + Văn)*2 + Lý + Hóa)/6) .Cách thức xếp loại như sau:
-- Xét điểm thấp nhất (DTN) của các 4 môn
-- Nếu DTB>5 và DTN>4 là “Lên Lớp”, ngược lại là lưu ban

DECLARE cs CURSOR FOR SELECT MAHS FROM DSHS
OPEN cs
DECLARE @mahs nvarchar(5), @dtb float, @toan float, @ly float, @van float, @hoa
float, @dtn float
FETCH NEXT FROM cs into @mahs
WHILE @@FETCH_STATUS=0
BEGIN
declare @xl nchar(25)
select @toan=toan, @van=van, @hoa=hoa, @ly=ly,
@dtb=round((toan*2+van*2+ly+hoa)/6,2) from DIEM where MAHS=@mahs
set @dtn=@toan
if @dtn>@van set @dtn=@van
if @dtn>@hoa set @dtn=@hoa
if @dtn>@ly set @dtn=@ly
IF (@dtb> 5 AND @dtn> 4) SET @xl=N'Lên lớp'
ELSE SET @xl=N'Lưu ban'
Update dshs set XepLoai=@xl,dtbc=@dtb where MAHS=@mahs
FETCH NEXT FROM cs into @mahs
END
CLOSE cs
DEALLOCATE cs

CREATE VIEW DS_KETTHUCNAMHOC AS 
SELECT TOP 1000 DSHS.MAHS, DSHS.HO + ' ' + DSHS.TEN AS HoTen, DSHS.NGAYSINH, IIF(DSHS.NU = 0, 'Nam',N'Nữ') AS GIOITINH,
DIEM.TOAN,DIEM.LY,DIEM.HOA,DIEM.VAN, DSHS.dtbc, DSHS.XEPLOAI FROM DSHS JOIN DIEM
ON DSHS.MAHS = DIEM.MAHS
ORDER BY DSHS.XEPLOAI



SELECT * FROM DS_KETTHUCNAMHOC

-- 4. Tạo view danh sách HOC SINH XUAT SAC bao gồm các học sinh có DTB>=8.5 và
-- DTN>=8 với các trường: Lop, Mahs, Hoten, Namsinh (năm sinh), Nu, Toan, Ly, Hoa, Van,
-- DTN, DTB


Declare hs cursor for select mahs from DSHS
Open hs
Declare @mahs nvarchar(5), @dtb float
Fetch next from hs into @mahs
While (@@fetch_status = 0)
begin
select @dtb=round((toan*2+ van*2+hoa+ly)/6,2) from diem where
MAHS=@mahs
update dshs set dtbc=@dtb where MAHS=@mahs
Fetch next from hs into @mahs
end
Close hs; Deallocate hs

CREATE VIEW DS_HSXUATSAC AS 
SELECT DSHS.MALOP ,DSHS.MAHS, DSHS.HO + ' ' + DSHS.TEN AS HoTen, DSHS.NGAYSINH, YEAR(DSHS.NGAYSINH) AS Namsinh,
IIF(DSHS.NU = 0, 'Nam',N'Nữ') AS GIOITINH, DIEM.TOAN,DIEM.LY,DIEM.HOA,DIEM.VAN,
CASE
WHEN DIEM.TOAN <= DIEM.LY AND DIEM.TOAN <= DIEM.HOA AND DIEM.TOAN <= DIEM.VAN THEN DIEM.TOAN
WHEN DIEM.LY <= DIEM.TOAN AND DIEM.LY <= DIEM.HOA AND DIEM.LY <= DIEM.VAN THEN DIEM.LY
WHEN DIEM.HOA <= DIEM.TOAN AND DIEM.HOA <= DIEM.LY AND DIEM.HOA <= DIEM.VAN THEN DIEM.HOA
WHEN DIEM.VAN <= DIEM.TOAN AND DIEM.VAN <= DIEM.LY AND DIEM.VAN <= DIEM.HOA THEN DIEM.VAN
END AS dtn, DSHS.dtbc
FROM DSHS JOIN DIEM
ON DSHS.MAHS = DIEM.MAHS
WHERE DSHS.dtbc >= 8.5 AND 
        DIEM.TOAN >= 8 AND
        DIEM.LY >= 8 AND
        DIEM.HOA >= 8 AND
        DIEM.VAN >= 8
    
SELECT * FROM DS_HSXUATSAC



-- 5. Tạo view danh sách HOC SINH DAT THU KHOA KY THI bao gồm các học sinh xuất
-- sắc có DTB lớn nhất với các trường: Lop, Mahs, Hoten, Namsinh, Nu, Toan, Ly, Hoa, Van,
-- DTB

Declare hs cursor for select mahs from DSHS
Open hs
Declare @mahs nvarchar(5), @dtb float
Fetch next from hs into @mahs
While (@@fetch_status = 0)
begin
select @dtb=round((toan*2+van*2+hoa+ly)/6,2) from diem where
MAHS=@mahs
update dshs set dtbc=@dtb where MAHS=@mahs
Fetch next from hs into @mahs
end
Close hs; Deallocate hs

CREATE VIEW DS_HSDATTHUKHOA AS 
SELECT DSHS.MALOP ,DSHS.MAHS, DSHS.HO + ' ' + DSHS.TEN AS HoTen, YEAR(DSHS.NGAYSINH) AS Namsinh,
IIF(DSHS.NU = 0, 'Nam',N'Nữ') AS GIOITINH, DIEM.TOAN,DIEM.LY,DIEM.HOA,DIEM.VAN, DSHS.dtbc
FROM DSHS JOIN DIEM
ON DSHS.MAHS = DIEM.MAHS
WHERE DSHS.dtbc = ( SELECT MAX(DSHS.dtbc) FROM DSHS )


SELECT * FROM DS_HSDATTHUKHOA


-- Bài 3: Cho CSDL về quản lý bán hàng trong file QLSinhVien.sql 

-- 1. Tạo login Login1, tạo User1 cho Login1

EXEC sp_addlogin Login1
use QLSV
EXEC sp_adduser Login1, User1


-- 2. Phân quyền Select trên bảng DSSinhVien cho User1

GRANT SELECT ON DSSinhVien to User1


-- 3. Đăng nhập để kiểm tra (chup anh)

-- 4. Tạo login Login2, tạo User2 cho Login2


EXEC sp_addlogin Login2
use QLSV
EXEC sp_adduser Login2, User2

-- 5. Phân quyền Update trên bảng DSSinhVien cho User2, người này có thể cho phép người
-- khác sử dụng quyền này


grant update ON DSSinhVien to User2 with grant option


