using Microsoft.EntityFrameworkCore;
using QLBH_LeVanHoa_65131052.Models;

namespace QLBH_LeVanHoa_65131052
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllersWithViews();
            var connectionString = builder.Configuration.GetConnectionString("QLBH");

            // 2. Kiểm tra xem có đọc được không (Quan trọng!)
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("Không tìm thấy chuỗi kết nối 'QLBH' trong appsettings.json. Hãy kiểm tra lại file cấu hình!");
            }

            // 3. Đăng ký DbContext
            builder.Services.AddDbContext<QLBHContext>(options =>
                options.UseSqlServer(connectionString));
            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
            }
            app.UseRouting();

            app.UseAuthorization();

            app.MapStaticAssets();
            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=KhachHangs}/{action=Index}/{id?}")
                .WithStaticAssets();

            app.Run();
        }
    }
}
