using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace QLBH_LeVanHoa_65131052.Models
{
    public partial class QLBHContext
    {
        public List<Tinh> Tinh_GetAll()
        {
            return Tinhs.FromSqlRaw("EXEC Tinh_GetAll").ToList();
        }

        public Tinh? Tinh_GetById(int maTinh)
        {
            var p = new SqlParameter("@MaTinh", maTinh);
            return Tinhs.FromSqlRaw("EXEC Tinh_GetById @MaTinh", p).AsEnumerable().FirstOrDefault();
        }

        public void Tinh_Insert(Tinh tinh)
        {
            var p = new SqlParameter("@TenTinh", tinh.TenTinh);
            Database.ExecuteSqlRaw("EXEC Tinh_Insert @TenTinh", p);
        }

        public void Tinh_Update(Tinh tinh)
        {
            var p = new[] {
                new SqlParameter("@MaTinh", tinh.MaTinh),
                new SqlParameter("@TenTinh", tinh.TenTinh)
            };
            Database.ExecuteSqlRaw("EXEC Tinh_Update @MaTinh, @TenTinh", p);
        }

        public void Tinh_Delete(int maTinh)
        {
            var p = new SqlParameter("@MaTinh", maTinh);
            Database.ExecuteSqlRaw("EXEC Tinh_Delete @MaTinh", p);
        }

        // ======================================================
        // 2. Xa
        // ======================================================
        public List<Xa> Xa_GetAll()
        {
            return Xas.FromSqlRaw("EXEC Xa_GetAll").ToList();
        }

        public Xa? Xa_GetById(int maXa)
        {
            var p = new SqlParameter("@MaXa", maXa);
            return Xas.FromSqlRaw("EXEC Xa_GetById @MaXa", p).AsEnumerable().FirstOrDefault();
        }

        public void Xa_Insert(Xa xa)
        {
            var p = new[] {
                new SqlParameter("@TenXa", xa.TenXa),
                new SqlParameter("@MaTinh", xa.MaTinh)
            };
            Database.ExecuteSqlRaw("EXEC Xa_Insert @TenXa, @MaTinh", p);
        }

        public void Xa_Update(Xa xa)
        {
            var p = new[] {
                new SqlParameter("@MaXa", xa.MaXa),
                new SqlParameter("@TenXa", xa.TenXa),
                new SqlParameter("@MaTinh", xa.MaTinh)
            };
            Database.ExecuteSqlRaw("EXEC Xa_Update @MaXa, @TenXa, @MaTinh", p);
        }

        public void Xa_Delete(int maXa)
        {
            var p = new SqlParameter("@MaXa", maXa);
            Database.ExecuteSqlRaw("EXEC Xa_Delete @MaXa", p);
        }
        public List<KhachHang> KhachHang_GetAll(string? search = null)
        {
            var list = new List<KhachHang>();

            // 1. Tạo kết nối và câu lệnh
            using var cmd = Database.GetDbConnection().CreateCommand();
            cmd.CommandText = "KhachHang_GetAll";
            cmd.CommandType = CommandType.StoredProcedure;

            // 2. Thêm tham số
            cmd.Parameters.Add(new SqlParameter("@Search", string.IsNullOrEmpty(search) ? DBNull.Value : search));

            // 3. Mở kết nối
            if (Database.GetDbConnection().State != ConnectionState.Open)
            {
                Database.OpenConnection();
            }

            // 4. Đọc dữ liệu
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                // 5. Map từng dòng SQL vào đối tượng C#
                var kh = new KhachHang
                {
                    MaKh = reader["MaKH"].ToString(),
                    TenKh = reader["TenKH"].ToString(),
                    // SỬA: Đọc đúng tên cột trong SQL (DienThoaiKH, DiaChiKH)
                    DienThoaiKh = reader["DienThoaiKH"] != DBNull.Value ? reader["DienThoaiKH"].ToString() : null,
                    EmailKh = reader["EmailKH"] != DBNull.Value ? reader["EmailKH"].ToString() : null, // Thêm đọc Email
                    DiaChiKh = reader["DiaChiKH"] != DBNull.Value ? reader["DiaChiKH"].ToString() : null,
                    AnhKh = reader["AnhKH"] != DBNull.Value ? reader["AnhKH"].ToString() : null,
                    MaXa = (short)Convert.ToInt32(reader["MaXa"]),

                    // Thuộc tính mở rộng
                    TenXa = reader["TenXa"].ToString(),
                    TenTinh = reader["TenTinh"].ToString()
                };
                list.Add(kh);
            }

            // Đóng kết nối nếu cần (using tự xử lý nhưng đóng explicit cho chắc)
            if (Database.GetDbConnection().State == ConnectionState.Open) Database.CloseConnection();

            return list;
        }

        public KhachHang? KhachHang_GetById(string maKH)
        {
            KhachHang? kh = null;

            using var cmd = Database.GetDbConnection().CreateCommand();
            cmd.CommandText = "KhachHang_GetById";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add(new SqlParameter("@MaKH", maKH));

            if (Database.GetDbConnection().State != ConnectionState.Open) Database.OpenConnection();

            using var reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                kh = new KhachHang
                {
                    MaKh = reader["MaKH"].ToString(),
                    TenKh = reader["TenKH"].ToString(),
                    // SỬA: Đọc đúng tên cột trong SQL
                    DienThoaiKh = reader["DienThoaiKH"] != DBNull.Value ? reader["DienThoaiKH"].ToString() : null,
                    EmailKh = reader["EmailKH"] != DBNull.Value ? reader["EmailKH"].ToString() : null, // Thêm đọc Email
                    DiaChiKh = reader["DiaChiKH"] != DBNull.Value ? reader["DiaChiKH"].ToString() : null,
                    AnhKh = reader["AnhKH"] != DBNull.Value ? reader["AnhKH"].ToString() : null,
                    MaXa = (short)Convert.ToInt32(reader["MaXa"]),

                    TenXa = reader["TenXa"].ToString(),
                    TenTinh = reader["TenTinh"].ToString()
                };
            }

            if (Database.GetDbConnection().State == ConnectionState.Open) Database.CloseConnection();

            return kh;
        }

        public string KhachHang_Insert(KhachHang kh)
        {
            using var cmd = Database.GetDbConnection().CreateCommand();
            cmd.CommandText = "KhachHang_Insert";
            cmd.CommandType = CommandType.StoredProcedure;

            // Lưu ý: Kiểm tra kỹ tên thuộc tính TenKh hay TenKH
            cmd.Parameters.Add(new SqlParameter("@TenKH", kh.TenKh));
            cmd.Parameters.Add(new SqlParameter("@DienThoaiKH", kh.DienThoaiKh ?? (object)DBNull.Value));
            cmd.Parameters.Add(new SqlParameter("@EmailKH", kh.EmailKh ?? (object)DBNull.Value)); // <-- Thêm dòng này
            cmd.Parameters.Add(new SqlParameter("@DiaChiKH", kh.DiaChiKh ?? (object)DBNull.Value));
            cmd.Parameters.Add(new SqlParameter("@AnhKH", kh.AnhKh ?? (object)DBNull.Value));
            cmd.Parameters.Add(new SqlParameter("@MaXa", kh.MaXa));

            if (Database.GetDbConnection().State != ConnectionState.Open)
            {
                Database.OpenConnection();
            }

            string maKH = string.Empty;
            using var reader = cmd.ExecuteReader();
            if (reader.Read()) maKH = reader[0].ToString();

            // Không cần CloseConnection nếu dùng using, nhưng đóng cho chắc
            if (Database.GetDbConnection().State == ConnectionState.Open)
            {
                Database.CloseConnection();
            }

            return maKH;
        }

        public void KhachHang_Update(KhachHang kh)
        {
            var p = new[] {
                new SqlParameter("@MaKH", kh.MaKh),
                new SqlParameter("@TenKH", kh.TenKh),
                new SqlParameter("@DienThoaiKH", kh.DienThoaiKh ?? (object)DBNull.Value),
                new SqlParameter("@EmailKH", kh.EmailKh ?? (object)DBNull.Value), // <-- Thêm dòng này
                new SqlParameter("@DiaChiKH", kh.DiaChiKh ?? (object)DBNull.Value),
                new SqlParameter("@AnhKH", kh.AnhKh ?? (object)DBNull.Value),
                new SqlParameter("@MaXa", kh.MaXa)
            };
            // SỬA: Chuỗi SQL gọi lệnh Update cũng phải khớp tham số
            Database.ExecuteSqlRaw("EXEC KhachHang_Update @MaKH, @TenKH, @DienThoaiKH, @EmailKH, @DiaChiKH, @AnhKH, @MaXa", p);
        }

        public void KhachHang_Delete(string maKH)
        {
            var p = new SqlParameter("@MaKH", maKH);
            Database.ExecuteSqlRaw("EXEC KhachHang_Delete @MaKH", p);
        }
    }
}
