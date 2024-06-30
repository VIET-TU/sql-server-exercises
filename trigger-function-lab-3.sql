

--1. Kiểm soát giới tính của nhân viên chỉ được nhập giá trị là ‘Nam’ hoặc ‘Nữ’

create or alter trigger cau1_trigger on NHANVIEN 
after insert , update 
as begin
    if exists ( select 1 from inserted  where not ([Gioi Tinh] = N'Nam' or [Gioi Tinh] = N'Nữ'))
    begin
        throw 50000, 'Gioi tinh khong hop le', 1;
         rollback transaction
    end
end;

insert into NHANVIEN values(N'00040',N'Nguyễn Viet A',N'Ha Noi',N'Namd',null,null,null,null)


--2. Kiểm soát ngày vào làm (NgayLV) của nhân viên phải sau ngày sinh và đảm bảo nhân viên trên 18 tuổi


create or alter trigger cau2_trigger on NHANVIEN
after insert, update
as begin 
    if exists ( select 1 from inserted  where YEAR(NgayLV) <= YEAR(NgaySinh) or YEAR(GETDATE()) - YEAR(NgaySinh) < 18 )
    begin
       throw 50000, 'Ngay lam viec khong hop le hoac nhan vien chua du tuoi lam viec', 1;
         rollback transaction
    end
end;

 insert into NhanVien values (N'00026',N'Nguyễn van a',N'Ha noi',N'Nam','12','2021-3-4',null,null)


--3. Thêm trường Đơn vị tính vào bảng Hàng hóa. Kiểm soát đơn vị tính khi nhập hàng hóa chỉ được chứa từ “Cái”, “Hộp”, “Thùng”, “Kg”, “Chiếc”


ALTER TABLE HANGHOA ADD DonViTinh VARCHAR(10) NOT NULL;

create or alter trigger Cau3_trigger ON HANGHOA
for insert, update
as
begin
    if exists (select * from inserted where DonViTinh NOT IN ('Cái', 'Hộp', 'Thùng', 'Kg', 'Chiếc'))
    begin
         throw 50000, 'Dau vao don vi tinh khong hop le', 1;
         rollback transaction
    end
end;

insert into HangHoa values(N'0021',null,null,null,null,N'Canh')

drop trigger Trg3

select * from HangHoa

--4. Tạo trigger cập nhật tự động giá của bảng hàng hóa sang bảng chi tiết hóa đơn mỗi khi thêm mới bản ghi


alter table CT_HOADON add Gia money 

create or alter trigger cau4_trigger on CT_HOADON
after insert
as begin
    UPDATE CT_HOADON
    SET CT_HOADON.Gia = HANGHOA.GiaBan
    FROM CT_HOADON
     JOIN inserted ON CT_HOADON.MaHD = inserted.MaHD AND CT_HOADON.MaHH = inserted.MaHH
     JOIN HANGHOA ON CT_HOADON.MaHH = HANGHOA.MaHH;
end

insert into CT_HOADON([MaHD],[MaHH],[SL]) values('0002','0005',4)

select * from CT_HOADON where CT_HOADON.MaHD = '0002' and CT_HOADON.MaHH = '0005' and CT_HOADON.SL = 4


--5. Thêm trường ChietKhau vào bảng CT_Hoadon và cập nhật tự động trường này bằng 15% giá bán

alter table CT_HOADON add ChietKhau money;

create or alter trigger cau5_trigger on CT_HOADON
after insert
as begin
	update CT_HOADON 
	set ChietKhau = CT_HOADON.Gia * CT_HOADON.SL * 0.15
	from CT_HOADON join inserted 
	on  CT_HOADON.MaHD = inserted.MaHD and CT_HOADON.MaHH = inserted.MaHH
end;

insert into CT_HOADON([MaHD],[MaHH],[SL]) values('0007','0003',2)

select * from CT_HOADON where CT_HOADON.MaHD = '0003' and CT_HOADON.MaHH = '0002' 


--6. Thêm Trường ThanhTien và cập nhật tự động cho trường này

alter table  CT_HOADON add ThanhTien money;

create or alter trigger cau6_trigger on CT_HOADON
after insert, update
as begin
    update CT_HOADON 
	set CT_HOADON.ThanhTien = CT_HOADON.Gia * CT_HOADON.SL - CT_HOADON.Chietkhau
	from CT_HOADON JOIN inserted
	on CT_HOADON.MaHD = inserted.MaHD AND CT_HOADON.MaHH = inserted.MaHH
end;

insert into CT_HOADON([MaHD],[MaHH],[SL]) values('0003','0005',2)

select * from CT_HOADON where CT_HOADON.MaHD = '0003' and CT_HOADON.MaHH = '0005' 


--7. Cập nhật lại giá của bảng hàng hóa sang bảng chi tiết hóa đơn


create or alter trigger cau7_trigger on HANGHOA
after update
as begin
    update CT_HOADON
    set CT_HOADON.Gia = HANGHOA.GiaBan
    from CT_HOADON
    join inserted on CT_HOADON.MaHH = inserted.MaHH
    join HANGHOA on CT_HOADON.MaHH = HANGHOA.MaHH
	where CT_HOADON.MaHH = inserted.TenHH
END;


UPDATE HANGHOA
SET HANGHOA.GiaBan = '1000000'
WHERE HANGHOA.MaHH = '0007' 


select * from CT_HOADON where CT_HOADON.MaHH = '0007' 


SELECT * FROM CT_HOADON
--VI. Tạo FUNCTION
--1. Tạo hàm lấy danh sách nhân viên theo quê quán


create or alter function cau1(@quequan nvarchar(50)) returns table
as return(
    select *
	from Nhanvien
	 WHERE Nhanvien.QueQuan LIKE  N'%' +  @quequan + '%'
)


select * from cau1(N'Hà Nội')

-- cau 2

create or alter function cau2_ (@manv nvarchar(10), @ngay Date) returns table
as return (
   select * 
   from HoaDon 
   where MaNV=@manv and CONVERT(DATE, NgayLap) = @ngay)

select * from cau2_(N'0004','2015-4-2')


--3. Tạo hàm tính tổng tiền của từng hóa đơn với mã hóa đơn là tham số đầu vào

create or alter function cau3_(@MaHD nvarchar(20))
returns table
as return(
select SUM(CT_HOADON.SL* HANGHOA.GiaBan) as TongTien
from CT_HOADON join HANGHOA on CT_HOADON.MaHH = HANGHOA.MaHH
where CT_HOADON.MaHD = @MaHD
)

select * from cau3_('0003')



--4. Tạo hàm lấy danh sách nhà cung cấp theo mã hàng

create or alter function cau4_(@mh nvarchar(10))
returns table
as return(
select CT_PHIEUNHAP.MaHH, NHACUNGCAP.MaNCC, NHACUNGCAP.TenNCC
from NHACUNGCAP join PHIEUNHAP on NHACUNGCAP.MaNCC = PHIEUNHAP.MaNCC
join CT_PHIEUNHAP on PHIEUNHAP.MaPN = CT_PHIEUNHAP.MaPN
where CT_PHIEUNHAP.MaHH = @mh
)

select * from cau4_('0002')

--5. Tạo hàm lấy danh sách các mặt hàng theo mã nhà cung cấp


create or alter function cau5_ (@mancc nvarchar(10))
returns table
as return(
select HANGHOA.MaHH, TenHH, HangSX, GiaBan, DacDiem
from  HANGHOA join CT_PHIEUNHAP on HANGHOA.MaHH = CT_PHIEUNHAP.MaHH
join PHIEUNHAP on PHIEUNHAP.MaPN = CT_PHIEUNHAP.MaPN
where PHIEUNHAP.MaNCC = @mancc
)

select * from cau5_ ('0001')

--6. Cho danh sách các khách hàng ở một quận nào đó


create  or alter function cau6_ (@diachi nvarchar(20)) returns table
as return (
  select *
  from KhachHang
  where KhachHang.DiaChi like  N'%' + @diachi + '%'
)


select * from cau6_(N'Hà Nội')