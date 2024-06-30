

alter table tNhanVien add soluongsach int, tongtiensach money

update tNhanVien set soluongsach = 0

update tNhanVien set tongtiensach = 0


create or alter trigger cau2_trigger on tChiTietHDB
after insert
as begin
	declare @sls int, @tongtien money, @mnv varchar(50)
	select @sls = inserted.SLBan, @tongtien = tSach.DonGiaBan * inserted.SLBan,
	@mnv = tHoaDonBan.MaNV
	from inserted
	join tHoaDonBan on tHoaDonBan.SoHDB = inserted.SoHDB
	join tSach on tSach.MaSach = inserted.MaSach
	where tSach.MaNXB = 'NXB05'
	if exists (select * from inserted)
	begin
		update tNhanVien
		set soluongsach = (tNhanVien.soluongsach) + @sls,
		tongtiensach = (tNhanVien.tongtiensach) + @tongtien
		from tNhanVien
		where tNhanVien.MaNV = @mnv
	end
	if exists (select * from deleted)
	begin
		update tNhanVien
		set soluongsach = (tNhanVien.soluongsach) - @sls,
		tongtiensach = (tNhanVien.tongtiensach) - @tongtien
		from tNhanVien
		where tNhanVien.MaNV = @mnv
	end
	
end

insert into tHoaDonBan (SoHDB,MaNV,NgayBan,MaKH) values ('HDB14','NV01','2023-5-5','KH01')

insert into tChiTietHDB (SoHDB,MaSach,SLBan) values('HDB13','S04', 10)

delete from tChiTietHDB where tChiTietHDB.SoHDB = 'HDB13' and tChiTietHDB.MaSach = 'S04'

SELECT * FROM tNhanVien 



--Câu 2: Thêm trường Số lượng sách và Tổng tiền hàng vào bảng nhà cung cấp, cập nhật dữ liệu cho trường này mỗi khi thêm, xóa, sửa chi tiết nhập.
create or alter trigger Cau2trigger on tchitiethdn
after insert, update, delete
as begin
	declare @sohdn nvarchar(10), @sln int, @masach nvarchar(10), @ncc nvarchar(10), @dongia money
	declare @sohdn_de nvarchar(10), @sln_de int, @masach_de nvarchar(10), @ncc_de nvarchar(10), @dongia_de money
	--Bảng inserted (insert, update)
	select @sohdn=SoHDN, @masach=MaSach, @sln=SLNhap from inserted
	select @dongia=DonGiaBan from tSach where MaSach=@masach
	select @ncc=MaNCC from tHoaDonNhap where SoHDN=@sohdn
	update tNhaCungCap set
		SoLuongSach=isnull(SoLuongSach,0)+@sln,
		TongTienHang=isnull(TongTienHang,0)+ @sln*@dongia
	where MaNCC=@ncc

	--Bảng deleted (Delete, update)
	select @sohdn_de=SoHDN, @masach_de=MaSach, @sln_de=SLNhap from deleted
	select @dongia_de=DonGiaBan from tSach where MaSach=@masach_de
	select @ncc_de=MaNCC from tHoaDonNhap where SoHDN=@sohdn_de
	update tNhaCungCap set
		SoLuongSach=isnull(SoLuongSach,0) - @sln_de,
		TongTienHang=isnull(TongTienHang,0) - @sln_de*@dongia_de
	where MaNCC=@ncc_de
end

select * from tNhaCungCap
select * from tHoaDonNhap where mancc=N'NCC01'
select * from tChiTietHDN

insert into tChiTietHDN (SoHDN, MaSach, SLNhap) values('HDN01','S02', 2)
update tChiTietHDN set SLNhap=4 where SoHDN='HDN01' and MaSach='S02'
delete from tChiTietHDN where SoHDN='HDN01' and MaSach='S02'