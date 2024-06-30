use QLKhachSan

-- Câu 1: Tạo thủ tục có đầu vào là mã khách hàng, năm, đầu ra là số lượng hóa đơn
-- của mã mã khách hàng trong năm đó (năm được tính dựa trên ngày thanh toán).

create or alter procedure cau1_proc @mkh varchar(50), @nam int, @slhoadon int output
as begin
	select @slhoadon = count(HOADONTT.MaHDTT)
	from KHACHHANG
	join PHIEUDAT on  PHIEUDAT.MaKH = KHACHHANG.MaKH
	join HOADONTT on HOADONTT.MaBooking = PHIEUDAT.MaBooking
	where KHACHHANG.MaKH = @mkh and YEAR(HOADONTT.NgayLapHD) = @nam
end

declare @slhd int
exec cau1_proc 'KH0001', 2022, @slhd output
print 'so luong hoa don: ' +  cast(@slhd as varchar(50))

-- Câu 2: Tạo hàm có đầu vào là mã loại phòng, đầu ra là danh sách các thông tin chi
-- tiết các phòng của mã loại phòng đó, các thông tin đưa ra như bảng dưới đây (bảng
-- ví dụ dưới có mã loại phòng là ‘Standard01’)

create or alter function cau2_func(@malp varchar(50)) returns table
as return (
	select LOAIPHONG.MaLP, LOAIPHONG.Kieuphong, LOAIPHONG.Dientich, LOAIPHONG.Dongiaphong, PHONG.Maphong
	from LOAIPHONG
	join PHONG on PHONG.MaLP = LOAIPHONG.MaLP
	where LOAIPHONG.MaLP = @malp
)

select * from cau2_func('Standard01')


-- Câu 3: Thêm trường Số lượng phòng đặt vào bảng Phiếu đặt. Tạo Trigger cập nhật
-- tự động cho trường này mỗi khi thêm, sửa, xóa một bản ghi ở bảng Chi tiết phòng đặt.

alter table PHIEUDAT ADD soluongphong int
update  PHIEUDAT set soluongphong = 0 from PHIEUDAT

create or alter trigger cau3_trigger on CHITIETPHONGDAT
after insert,update, delete
as begin
	declare @mabooking varchar(50), @soluongphong int
	select @mabooking = inserted.MaBooking, @soluongphong = inserted.SLPhong from inserted

	update PHIEUDAT
		set PHIEUDAT.soluongphong = PHIEUDAT.soluongphong + @soluongphong
		from PHIEUDAT
		where PHIEUDAT.MaBooking = @mabooking


	declare @mabooking_del varchar(50), @soluongphong_del int
	select @mabooking_del = deleted.MaBooking, @soluongphong_del = deleted.SLPhong from deleted

	update PHIEUDAT
		set PHIEUDAT.soluongphong = PHIEUDAT.soluongphong -  @soluongphong_del
		from PHIEUDAT
		where PHIEUDAT.MaBooking = @mabooking_del
end

select * from PHIEUDAT where  PHIEUDAT.MaBooking =  'PD0014'


insert into CHITIETPHONGDAT (MaBooking,SLPhong,MaLP)
values ('PD0014','5','Deluxe01')

select * from PHIEUDAT where  PHIEUDAT.MaBooking =  'PD0014'

delete from CHITIETPHONGDAT where CHITIETPHONGDAT.MaBooking = 'PD0014' and CHITIETPHONGDAT.MaLP = 'Deluxe01'

select * from PHIEUDAT where  PHIEUDAT.MaBooking =  'PD0014'


-- Câu 4: Tạo View gồm các thông tin mã nhân viên, tên nhân viên, mã HDTT, Ngày
-- lập HD, Ngày thanh toán, phương thức thanh toán, mã booking, ngày đến dự kiến,
-- ngày đi dự kiến có ngày đến dự kiến từ ngày 12/12/2022 đến ngày 19/12/2022

create view cau4_view as
select NHANVIEN.MaNV, NHANVIEN.TenNV, HOADONTT.MaHDTT, HOADONTT.NgayLapHD, HOADONTT.NgayTT, HOADONTT.PhuongthucTT, 
	PHIEUDAT.MaBooking, PHIEUDAT.NgayDenDukien, PHIEUDAT.NgayDiDuKien
   from NHANVIEN
   join HOADONTT on HOADONTT.MaNV = NHANVIEN.MaNV
   join PHIEUDAT on PHIEUDAT.MaBooking = HOADONTT.MaBooking
   WHERE PHIEUDAT.NgayDenDukien BETWEEN '2022-12-12' AND '2022-12-19'


 select * from cau4_view

 -- Câu 5: Tạo login 

EXEC sp_addlogin NguyenDucThuan
EXEC sp_adduser NguyenDucThuan, NguyenDucThuan

EXEC sp_addlogin NguyenTienTai
EXEC sp_adduser NguyenTienTai, NguyenTienTai

GRANT SELECT, INSERT, UPDATE ON PhieuDat  to NguyenDucThuan with grant option

grant select, insert, update on PhieuDat to NguyenTienTai 

-- Câu 6: Tạo thủ tục có đầu vào là năm bắt đầu, năm kết thúc, đầu ra là ba tháng trong
-- năm có tổng doanh thu cao nhất (ví dụ từ năm 2020 đến năm 2022 thì tháng 6, 7, 8 là
-- những tháng có doanh thu cao nhất, tháng lấy theo ngày thanh toán).

create or alter proc cau6_procedure
@NamBD int, @NamKT int, @Thang int out
as begin 
	
	select  top 3 MONTH(NgayTT) as thang,
	SUM(Dongiaphong*CHITIETPHONGDAT.SLPhong*(1-KMPhong)*DATEDIFF(day,PHIEUTHUE.Thoigiancheckin,PHIEUTHUE.Thoigiancheckout)) as doanhthu
	from  PHIEUDAT join CHITIETPHONGDAT on CHITIETPHONGDAT.MaBooking = PHIEUDAT.MaBooking
	join LOAIPHONG on LOAIPHONG.MaLP = CHITIETPHONGDAT.MaLP
	join PHIEUTHUE on PHIEUTHUE.MaBooking = PHIEUDAT.MaBooking
	join HOADONTT on HOADONTT.MaBooking = PHIEUDAT.MaBooking
	where YEAR(NgayTT) >= @NamBD and YEAR(NgayTT) <= @NamKT
	group by MONTH(NgayTT)	
	order by (SUM(Dongiaphong*CHITIETPHONGDAT.SLPhong*(1-KMPhong)*DATEDIFF(day,PHIEUTHUE.Thoigiancheckin,PHIEUTHUE.Thoigiancheckout)) ) desc 

	end

declare @Thang int
exec cau6_procedure '2022','2023', @Thang out
print @Thang




