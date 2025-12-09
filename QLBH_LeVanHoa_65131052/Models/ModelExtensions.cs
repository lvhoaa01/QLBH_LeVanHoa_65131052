using System.ComponentModel.DataAnnotations.Schema;

namespace QLBH_LeVanHoa_65131052.Models
{
    public partial class Xa
    {
        [NotMapped]
        public string TenTinh { get; set; }
    }

    // 2. Mở rộng cho bảng Nhà Cung Cấp (Để hứng TenXa, TenTinh)
    public partial class NhaCC
    {
        [NotMapped]
        public string TenXa { get; set; }

        [NotMapped]
        public string TenTinh { get; set; }
    }

    // 3. Mở rộng cho bảng Khách Hàng (Đã làm rồi, nhưng để đây cho đủ bộ)
    public partial class KhachHang
    {
        [NotMapped]
        public string TenXa { get; set; }

        [NotMapped]
        public string TenTinh { get; set; }
    }

    // 4. Mở rộng cho bảng Sản Phẩm (Để hứng TenLoai, TenNCC)
    public partial class SanPham
    {
        [NotMapped]
        public string TenLoai { get; set; }

        [NotMapped]
        public string TenNCC { get; set; }
    }

    // 5. Mở rộng cho Đơn Bán Hàng (Để hứng TenKH)
    public partial class DonBanHang
    {
        [NotMapped]
        public string TenKH { get; set; }
    }

    // 6. Mở rộng cho Đơn Mua Hàng (Để hứng TenNCC)
    public partial class DonMuaHang
    {
        [NotMapped]
        public string TenNCC { get; set; }
    }

    // 7. Mở rộng cho Chi Tiết Bán Hàng (Để hứng TenSP)
    public partial class CTBH
    {
        [NotMapped]
        public string TenSP { get; set; }
    }

    // 8. Mở rộng cho Chi Tiết Mua Hàng (Để hứng TenSP)
    public partial class CTMH
    {
        [NotMapped]
        public string TenSP { get; set; }
    }
}
