use QLVanTai

 -- 1. Tạo hàm có đầu vào là lộ trình, đầu ra là số xe, mã trọng tải,
 -- số lượng vận tải, ngày đi, ngày
-- đến (SoXe, MaTrongTai, SoLuongVT, NgayDi, NgayDen.)

alter function cau1(@malotrinh nvarchar(255))
returns table
as return (
			 select SoXe, MaTrongTai, SoLuongVT, NgayDi, NgayDen from ChiTietVanTai
			 where ChiTietVanTai.MaLoTrinh = @malotrinh
		  )

select * from cau1(N'PK')


-- 2. Thiết lập hàm có đầu vào là số xe, đầu ra là thông tin về lộ trình


alter function cau2(@soxe nvarchar(255))
returns  table
as return (
			select * from LoTrinh
			where LoTrinh.MaLoTrinh in (
				select MaLoTrinh from ChiTietVanTai
				where ChiTietVanTai.SoXe = @soxe
				)
			)
			
select * from cau2('333')


-- 3.Tạo hàm có đầu vào là trọng tải, đầu ra là các số xe có trọng tải quy
-- định lớn hơn hoặc bằng trọng tải đó

alter function cau3(@trongtai int)
returns table
as return ( 
			select DISTINCT  ChiTietVanTai.SoXe, ChiTietVanTai.MaTrongTai, TrongTai.TrongTaiQD from ChiTietVanTai
			join TrongTai on TrongTai.MaTrongTai = ChiTietVanTai.MaTrongTai
			where TrongTai.TrongTaiQD >= @trongtai
		)

select * from TrongTai

	select * from cau3(8)

-- 4. Tạo hàm có đầu vào là trọng tải và mã lộ trình, đầu ra là số lượng xe có trọng tải quy định
-- lớn hơn hoặc bằng trọng tải đó và thuộc lộ trình đó.  

alter function cau4(@trongtai int, @malotrinh varchar(50)) 
returns table 
as return (
	select  COUNT(ChiTietVanTai.SoXe) AS TongSoLuongVT from ChiTietVanTai
	join TrongTai on TrongTai.MaTrongTai = ChiTietVanTai.MaTrongTai
	where  TrongTai.TrongTaiQD >= @trongtai and ChiTietVanTai.MaLoTrinh = @malotrinh
)

select * from cau4(9, 'HN')



-- 5 Tạo thủ tục có đầu vào Mã lộ trình đầu ra là số lượng xe thuộc lộ trình đó.

create procedure cau5 @malotrinh varchar(50),@soluongxe int output as
begin
		select @soluongxe =  COUNT(ChiTietVanTai.SoXe)   from ChiTietVanTai
		where   ChiTietVanTai.MaLoTrinh = @malotrinh
end

declare @tongxe int
exec cau5 'HN', @tongxe output
print @tongxe


-- 6. Tạo thủ tục có đầu vào là mã lộ trình, năm vận tải, đầu ra là số tiền theo mã lộ trình và năm
-- vận tải đó

create or alter procedure cau6 @malotrinh varchar(10), @namvantai int, @sotien money output as
begin 
	select @sotien = sum(LoTrinh.DonGia) 
	from ChiTietVanTai
	join LoTrinh on LoTrinh.MaLoTrinh = ChiTietVanTai.MaLoTrinh
	where ChiTietVanTai.MaLoTrinh = @malotrinh AND year(ChiTietVanTai.NgayDi) = @namvantai
	GROUP BY ChiTietVanTai.MaLoTrinh
end


declare @sotien money
exec cau6 'HN', 2014, @sotien output
print @sotien

-- 7. Tạo thủ tục có đầu vào là số xe, năm vận tải, đầu ra là số tiền theo số xe và năm vận tảiđó

create or alter procedure cau7 @soxe int, @namvantai int, @sotien money output as
begin 
	select @sotien = sum(LoTrinh.DonGia)
	from ChiTietVanTai
	join LoTrinh on LoTrinh.MaLoTrinh = ChiTietVanTai.MaLoTrinh
	where ChiTietVanTai.SoXe = @soxe and year(ChiTietVanTai.NgayDi) = @namvantai
	group by ChiTietVanTai.SoXe
end


declare @sotien_ money
exec cau7 '333', 2014, @sotien_ output
print @sotien_


-- 8. Tạo thủ tục có đầu vào là mã trọng tải, đầu ra là số lượng xe vượt quá trọng tải quy định
-- của mã trọng tải đó.
create or alter procedure cau8 @matrongtai varchar(50), @soluongxe int output as
begin 
	select @soluongxe =  COUNT(ChiTietVanTai.SoXe)   from ChiTietVanTai
		join TrongTai on TrongTai.MaTrongTai = ChiTietVanTai.MaTrongTai
		where   ChiTietVanTai.MaTrongTai = @matrongtai and
			ChiTietVanTai.SoLuongVT > TrongTai.TrongTaiQD
end


declare @slx int
exec cau8 '52', @slx output
print @slx
		


--- Bai 2
use QLNhanVien

-- 1. Tạo hàm với đầu vào là năm, đầu ra là danh sách nhân viên sinh vào năm đó

create function cau1_(@namsinh int) returns table
as return (
	select * from tNhanVien
	where year(tNhanVien.NTNS) = @namsinh
)

select * from cau1_('1963')

-- 2. Tạo hàm với đầu vào là số thâm niên (số năm làm việc) đầu ra là danh sách nhân viên có thâm niên đó
create or alter function cau2_(@namlamviec int) returns table
as return(
	select tNhanVien.MaNV,  tNhanVien.HO + tNhanVien.TEN as hoten, year(tNhanVien.NgayBD) as nambatdau, 
	 (DATEDIFF(YEAR, tNhanVien.NgayBD, GETDATE()) - 
        CASE 
            WHEN DATEPART(DAYOFYEAR, tNhanVien.NgayBD) > DATEPART(DAYOFYEAR, GETDATE()) 
            THEN 1 
            ELSE 0 
        END) as sothamnien, tNhanVien.NgayBD
	from tNhanVien
	where  (DATEDIFF(YEAR, tNhanVien.NgayBD, GETDATE()) - 
        CASE 
            WHEN DATEPART(DAYOFYEAR, tNhanVien.NgayBD) > DATEPART(DAYOFYEAR, GETDATE()) 
            THEN 1 
            ELSE 0 
        END) = @namlamviec
)
select * from cau2_(30)

-- 3. Tạo hàm đầu vào là chức vụ đầu ra là những nhân viên cùng chức vụ đó
create   function cau3_(@chuvu varchar(50)) returns table
as return (
	select tNhanVien.MaNV, tNhanVien.HO + tNhanVien.TEN as hoten, tChiTietNhanVien.ChucVu
	from tNhanVien
	join tChiTietNhanVien on tChiTietNhanVien.MaNV = tNhanVien.MaNV
	where tChiTietNhanVien.ChucVu = @chuvu
)



select * from cau3_('PGD')

-- 4. Tạo hàm đưa ra thông tin về nhân viên được tăng lương của ngày hôm nay (giả sử 3 năm lên lương 1 lần)
create or alter function cau4_() returns table
as return (
	select *
	from tNhanVien
	where ((year(GETDATE()) - year(tNhanVien.NgayBD)) % 3) = 0
			and month(tNhanVien.NgayBD) = month(getdate())
			and day(tNhanVien.NgayBD) = day(getdate()) 

)

select * from Cau4_() 

-- CAU 5

CREATE or ALTER  FUNCTION cau5_()
RETURNS @table_luongNV TABLE ( MaNV NVARCHAR(3), HTNV NVARCHAR(255),Luong MONEY, BHXH MONEY, BHYT MONEY, BHTN MONEY, ThueTNCN MONEY, PhuCap MONEY, ThucLinh MONEY ) AS
BEGIN
	DECLARE @SoNV INT, @i INT = 1, @MaNV NVARCHAR(3), @HTNV NVARCHAR(255), @HSLuong TINYINT, @MucDoCV NVARCHAR(1), 
	@PhuCap MONEY, @Luong MONEY, @ThuNhap MONEY, @ThueTNCN MONEY, @GTGC TINYINT;
	SELECT @SoNV = Count(*) FROM tNhanVien;
	WHILE @i <= @SoNV
	BEGIN
		SELECT @MaNV = TempMaNV.MaNV,@HTNV = TempMaNV.HOTEN  ,@HSLuong = HSLuong, @MucDoCV = left(MucDoCV, 1), @GTGC = GTGC
		FROM
		(
			SELECT tNhanVien.MaNV,tNhanVien.HO + tNhanVien.TEN AS HOTEN, HSLuong, MucDoCV, GTGC, ROW_NUMBER() OVER (ORDER BY tNhanVien.MaNV) AS RowNumber
				FROM tNhanVien JOIN tChiTietNhanVien ON tNhanVien.MaNV = tChiTietNhanVien.MaNV
		)
		AS TempMaNV
		WHERE RowNumber = @i
		IF (@MucDoCV = N'A') SELECT @PhuCap = 10000000 ELSE IF (@MucDoCV = N'B') SELECT @PhuCap = 8000000 ELSE SELECT @PhuCap = 5000000
		SELECT @Luong = 1490000 * @HSLuong + @PhuCap,
				@ThuNhap = @Luong * 0.895 - 11000000 - isnull(@GTGC, 0) * 4400000
		IF (@ThuNhap <= 0)
			SELECT @ThueTNCN = 0
		ELSE IF (@ThuNhap <= 5000000) 
			SELECT @ThueTNCN = @ThuNhap * 0.05
		ELSE IF (@ThuNhap <= 10000000) 
			SELECT @ThueTNCN = @ThuNhap * 0.1 - 250000
		ELSE IF (@ThuNhap <= 18000000) 
			SELECT @ThueTNCN = @ThuNhap * 0.15 - 750000
		ELSE IF (@ThuNhap <= 32000000)
			SELECT @ThueTNCN = @ThuNhap * 0.2 - 1650000
		ELSE IF (@ThuNhap <= 52000000)
			SELECT @ThueTNCN = @ThuNhap * 0.25 - 3250000
		ELSE IF (@ThuNhap <= 80000000)
			SELECT @ThueTNCN = @ThuNhap * 0.3 - 5850000
		ELSE 
			SELECT @ThueTNCN = @ThuNhap * 0.35 - 9850000
		INSERT INTO @table_luongNV (MaNV, HTNV,Luong, BHXH, BHYT, BHTN, ThueTNCN, PhuCap, ThucLinh)
		VALUES (@MaNV, @HTNV,@Luong, @Luong * 0.08, @Luong * 0.015, @Luong * 0.01, @ThueTNCN, @PhuCap, @Luong * 0.895 - @ThueTNCN)
		SET @i = @i + 1;
	END
	RETURN
END


SELECT * FROM cau5_()

--6. Tạo thủ tục có đầu vào là mã phòng, đầu ra là số nhân viên của phòng đó và tên trưởng phòng
go
create procedure Cau_6
	@maphong varchar(5),
	@tentruongphong nvarchar(50) output, 
	@sonhanvien int output
as 
begin 
  select @sonhanvien = COUNT(*)
  from tNhanVien
  where MaPB = @maphong

  -- Lấy tên trưởng phòng của phòng
  select @tentruongphong = HO + ' ' + TEN
  from tNhanVien join tChiTietNhanVien on tNhanVien.MaNV = tChiTietNhanVien.MaNV
  where tNhanVien.MaPB = @maphong and tChiTietNhanVien.ChucVu = 'TP'
end

go
declare @tentruongphong nvarchar(255), @sonhanvien int
exec Cau_6 'VP', @tentruongphong output, @sonhanvien output
select @sonhanvien as SoNhanVien
select @tentruongphong as TenTruongPhong


-- 6. Tạo thủ tục có đầu vào là mã phòng, đầu ra là số nhân viên của phòng đó và tên trưởng phòng
create or alter procedure cau6_ @maphong varchar(10), @sonhanvien int output, @tentruongphong nvarchar(255) output as
begin 
	
	select @tentruongphong = tNhanVien.HO + tNhanVien.TEN from tNhanVien
	join tChiTietNhanVien on tNhanVien.MaNV = tChiTietNhanVien.MaNV
	where tNhanVien.MaPB = @maphong and tChiTietNhanVien.ChucVu = 'TP'

	select @sonhanvien = count(tNhanVien.MaNV)
	from tNhanVien 
	where tNhanVien.MaPB = @maphong
end

declare @sonhavien int, @tentruongphong nvarchar(255)
exec cau6_ 'KH',@sonhavien output, @tentruongphong output
print @sonhavien 
print @tentruongphong


-- 7. Tạo thủ tục có đầu vào là mã phòng, tháng, năm, đầu ra là số tiền lương của phòng đó
-- Tạo hàm tính lương của nhân viên



create or alter procedure cau7_ @maphong varchar(50), @thang int, @nam int, @tongtienluong money output as
begin
    select @tongtienluong = sum(cau5_.ThucLinh)
    from dbo.cau5_() as cau5_
    inner join tNhanVien  on cau5_.MaNV = tNhanVien.MaNV
    where tNhanVien.MaPB = @maphong and month(tNhanVien.NgayBD) = @thang and year(tNhanVien.NgayBD) = @nam
end

declare @tongtienluong_ MONEY
exec cau7_ 'TC', 5, 1990,@tongtienluong_ output
print @tongtienluong_
