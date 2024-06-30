
use QLHocSinh

 -- 1. Viết một Trigger gắn với bảng DIEM dựa trên sự kiện Insert, Update để tự động cập nhật
-- điểm trung bình của học sinh khi thêm mới hay cập nhật bảng điểm
-- Điểm trung bình= ((Toán +Văn)*2+Lý+Hóa)/6

create or alter trigger cau1 on Diem
after insert,update
as begin

	update DIEM
	set DIEM.DTB = ( (inserted.TOAN + inserted.VAN) * 2 + inserted.LY + inserted.HOA ) / 6
	from DIEM
	join inserted on inserted.MAHS = DIEM.MAHS
end

insert into DIEM values ('00004', 8,8,8,8,null,null);

drop trigger cau1


select * from DIEM where DIEM.MAHS = '00002'

-- 2. Viết một Trigger gắn với bảng DIEM dựa trên sự kiện Insert, Update để tự động xếp loại
-- học sinh, cách thức xếp loại như sau
-- Nếu Điểm trung bình>=5 là lên lớp, ngược lại là lưu ban

create or alter  trigger cau2_trigger on Diem
after insert, update
as begin
	declare @dtb float
	select @dtb = ( (inserted.TOAN + inserted.VAN) * 2 + inserted.LY + inserted.HOA ) / 6
	from inserted
	update DIEM
	set DIEM.DTB = @dtb,
	 DIEM.XEPLOAI = (
		CASE
			WHEN @dtb >=5 THEN N'lên lớp'
			else N'lưu ban'
		end
	)
	from DIEM
	join inserted on inserted.MAHS = DIEM.MAHS
END

insert into DIEM values ('00009', 8,8,8,8,null,null);

select * from DIEM where DIEM.MAHS = '00009'

drop trigger cau2_trigger

-- 3. Viết một Trigger gắn với bảng DIEM dựa trên sự kiện Insert, Update để tự động xếp loại
-- học sinh, cách thức xếp loại như sau
-- Xét điểm thấp nhất (DTN) của các 4 môn
-- Nếu DTB>=5 và DTN>=4 là “Lên Lớp”, ngược lại là lưu ban

	create or alter  trigger cau3_trigger on Diem
	after insert, update
	as begin
		declare @dtb float,@dtn float
		select @dtb = ( (TOAN + VAN) * 2 + LY + HOA ) / 6,
		@dtn = (
			case 
				when TOAN <= Van AND TOAN <= LY and TOAN <= HOA then TOAN
				when VAN <= Toan AND VAN <= LY and VAN <= HOA then VAN
				when LY <= TOAN AND LY <= VAN and LY <= HOA then LY
				else HOA
			end
		)
		from inserted
		update DIEM
		set DIEM.DTB = @dtb,
		 DIEM.XEPLOAI = (
			CASE
				WHEN @dtb >=5 and @dtn >=4 THEN N'lên lớp'
				else N'lưu ban'
			end
		)
		from DIEM
		join inserted on inserted.MAHS = DIEM.MAHS
	END

insert into DIEM values ('00012', 8,8,8,3,null,null);
	
select * from DIEM where DIEM.MAHS = '00012'


-- 4. Viết một trigger xóa tự động bản ghi về điểm học sinh khi xóa dữ liệu học sinh đó trong DSHS

create trigger cau4_trigger on DSHS
after delete
as begin
	declare @mahs varchar(50)
	select @mahs = MAHS from deleted
	delete from DIEM WHERE DIEM.MAHS = @mahs
end

select * from DIEM WHERE MAHS = '00714'

delete from DSHS where MAHS = '00714'



-- Bài tập 2:

USE QLKhachSan_

-- 1. Viết truy vấn tạo bảng doanh thu (tDoanhThu) gồm các trường
create table tDoanhThu (
	MaDK varchar(50) ,
	LoaiPhong nvarchar(255) ,
	SoNgayO int ,
	ThucThu money,
)

-- 2. Tạo Trigger tính tiền và điền tự động vào bảng tDoanhThu như sau:

create or alter trigger cau2 on tDangKy
after insert
as begin
	declare @MaDK varchar(50), @LoaiPhong nvarchar(255), @SoNgayO int ,  @ThucThu money
	select  @MaDK = inserted.MaDK,@SoNgayO = DATEDIFF(day,NgayVao,NgayRa), @LoaiPhong = inserted.LoaiPhong from inserted
	select  @ThucThu = (
		case 
			when @SoNgayO < 10 then tLoaiPhong.DonGia * @SoNgayO
			when 10 <= @SoNgayO and @SoNgayO  < 30 then tLoaiPhong.DonGia * @SoNgayO * 0.95
			when @SoNgayO >= 30 then tLoaiPhong.DonGia * @SoNgayO * 0.9
		end
	)
	from tLoaiPhong 
	where tLoaiPhong.LoaiPhong = @LoaiPhong
	insert into tDoanhThu values(@MaDK, @LoaiPhong, @SoNgayO, @ThucThu)
end



insert into tDangKy(MaDK,SoPhong,LoaiPhong,NgayVao,NgayRa) values ('022','601','A','2023-11-5','2023-12-22')

select * from tDoanhThu where tDoanhThu.MaDK = '022'

drop trigger cau2

-- 3. Thêm trường DonGia vào bảng tDangKy, tạo trigger cập nhật tự động cho trường này.

alter table tDangKy add DonGia money null

create or alter trigger cau3 on tDangKy
after insert,update
as begin
	
	declare @madk varchar(50),@loaiphong varchar(50), @dongia money
	select @madk = inserted.MaDK, @loaiphong = inserted.LoaiPhong from inserted
	select @dongia = tLoaiPhong.DonGia from tLoaiPhong where tLoaiPhong.LoaiPhong = @loaiphong
	update tDangKy
	set tDangKy.DonGia = @dongia
	from tDangKy
	where tDangKy.MaDK = @madk

end

insert into tDangKy values ('019','601','A','2023-11-5','2023-11-8',null)

select * from tDangKy where tDangKy.MaDK = '019'



-- 4. Thêm trường tổng tiêu dùng (TongTieuDung) và bảng khách hàng và tính tự động tổng
-- tiền khách hàng đã trả cho khách sạn mỗi khi thêm, sửa, xóa bản tDangKy

alter table tKhachHang add TongTieuDung money
update tKhachHang set TongTieuDung = 0 from tKhachHang

create or alter trigger cau4 on tDangKy
after insert,update,delete
as begin

	declare @MaDK varchar(50), @LoaiPhong nvarchar(255), @SoNgayO int ,@dongia money ,@ThucThu money , @loaikh int
	select  @MaDK = inserted.MaDK,@SoNgayO = DATEDIFF(day,NgayVao,NgayRa), @LoaiPhong = inserted.LoaiPhong from inserted
	select @dongia = tLoaiPhong.DonGia from tLoaiPhong where tLoaiPhong.LoaiPhong = @LoaiPhong
	select  @ThucThu = (
		case 
			when @SoNgayO < 10 then @dongia * @SoNgayO
			when 10 <= @SoNgayO and @SoNgayO  < 30 then @dongia * @SoNgayO * 0.95
			when @SoNgayO >= 30 then @dongia * @SoNgayO * 0.9
		end
	)
	select @loaikh = tChiTietKH.LoaiKH from tChiTietKH where tChiTietKH.MaDK = @MaDK
	update tKhachHang
	set tKhachHang.TongTieuDung = tKhachHang.TongTieuDung +  isnull(@ThucThu,0)
	from tKhachHang
	where tKhachHang.LoaiKH = @loaikh


	declare @MaDK_del varchar(50), @LoaiPhong_del nvarchar(255), @SoNgayO_del int , @dongia_del money ,@ThucThu_del money, @loaikh_del int
	select  @MaDK_del = deleted.MaDK,@SoNgayO_del = DATEDIFF(day,NgayVao,NgayRa), @LoaiPhong_del = deleted.LoaiPhong from deleted
	select @dongia_del = tLoaiPhong.DonGia from tLoaiPhong where tLoaiPhong.LoaiPhong = @LoaiPhong_del
	select  @ThucThu_del = (
		case 
			when @SoNgayO_del < 10 then @dongia_del * @SoNgayO_del
			when 10 <= @SoNgayO_del and @SoNgayO_del  < 30 then @dongia_del * @SoNgayO_del * 0.95
			when @SoNgayO_del >= 30 then @dongia_del * @SoNgayO_del * 0.9
		end
	)

	update tKhachHang
	set tKhachHang.TongTieuDung = tKhachHang.TongTieuDung -  isnull(@ThucThu_del,0)
	from tKhachHang
	join tChiTietKH on tChiTietKH.LoaiKH = tKhachHang.LoaiKH
	where tChiTietKH.MaDK = @MaDK_del
end


insert into tDangKy(MaDK,SoPhong,LoaiPhong,NgayVao,NgayRa) values ('009','601','A','2023-11-5','2023-11-8')
insert into tDangKy(MaDK,SoPhong,LoaiPhong,NgayVao,NgayRa) values ('010','601','A','2023-11-5','2023-11-8')

select * from tKhachHang

delete from tDangKy where tDangKy.MaDK = '009' 
delete from tDangKy where  tDangKy.MaDK = '010'

delete from tDoanhThu where tDoanhThu.MaDK = '009' or tDoanhThu.MaDK = '010'


