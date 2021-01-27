--Tran Ngoc Hien Long --1959016 --19BIT2

use QLBaoChi
go

--Đề 2:
--- Thêm thuộc tính “tình trạng giao” vào bảng đơn hàng.
--1. Viết stored procedure kiểm tra 1 đơn hàng đã giao xong hay chưa. Biết rằng,
--đơn hàng giao xong khi tất cả món hàng trong đơn hàng đã được giao đủ số
--lượng.
--o Gợi ý: chỉ cần tồn tại 1 sản phẩm chưa giao xong thì đơn hàng chưa giao
--xong.

--select COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH
--from INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME='Don_Hang'

alter table Don_Hang add TinhTrangGiao varchar(10)
go
drop proc usp_1
go
create proc usp_1
@madh char(4)
as
	
	declare @bien1 int = (
	select sum(ctg.soluong)
	from CT_PHIEUGIAO ctg, BAO b, CT_DONHANG ctd
	where ctd.maDH = 'DH01' and ctg.MaBao = b.MaBao and b.MaBao = ctd.MaBao and ctg.MaBao in (select MaBao from CT_DONHANG where MaDH = 'DH01') --this return 6 infact it's 4
	)
	declare @bien2 int =(
	select sum(soluong)
	from CT_DONHANG
	where MaDH = 'DH01'
	)
	select * from PHIEU_GIAO_BAO
	select * from CT_PHIEUGIAO
	select * from CT_DONHANG

	if @bien1 != @bien2
		begin
			update DON_HANG
			set TinhTrangGiao = 'chua'
			where MaDH = @madh
		end
	else
		begin
			update DON_HANG
			set TinhTrangGiao = 'xong'
			where MaDH = @madh
		end
go

exec usp_1 'DH02'
go
	

--2. Viết stored xuất danh sách các đơn hàng trong tháng này theo mẫu.
--Mã đơn hàng Tên khách hàng Tình trạng giao
--DH1 Khách hàng A Chưa giao xong
--DH2 Khách hàng A Đã giao xong
--Gọi thực thi các stored procedure trên
drop proc usp_2
go

create proc usp_2
as
	declare cur cursor for (select dh.MaDH, kh.HoTen, dh.TinhTrangGiao
								from DON_HANG dh, KHACH_HANG kh
								where dh.MaKH = kh.MaKH)

	open cur
	--select COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH
	--from INFORMATION_SCHEMA.COLUMNS
	--where TABLE_NAME='Khach_Hang'
	declare @madh char(4), @hoten nvarchar(100), @ttg varchar(10)

	fetch next from cur into @madh, @hoten, @ttg

	print '--------------------------------------------------'
	print N'Mã đơn hàng' +space(10)+ N'Tên Khách Hàng' + space(10) + N'Tình Trạng Giao'
	print '----------------------------------------------------------------------------'

	while(@@FETCH_STATUS = 0)
	begin
		print @madh + space(21-len(@madh)) + @hoten +space(24-len(@hoten)) + isnull(@ttg, 'chua')

		fetch next from cur into @madh, @hoten, @ttg

	end 

	close cur
	deallocate cur

go

exec usp_2
go