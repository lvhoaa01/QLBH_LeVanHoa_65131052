using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using QLBH_LeVanHoa_65131052.Models;

namespace QLBH_LeVanHoa_65131052.Controllers
{
    public class KhachHangsController : Controller
    {
        private readonly QLBHContext _context;
        private readonly IWebHostEnvironment _env;

        public KhachHangsController(QLBHContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        public IActionResult Index(string? search)
        {
            var list = _context.KhachHang_GetAll(search);
            return View(list);
        }

        public IActionResult Create()
        {
            // Dropdown chọn Xã
            ViewBag.Xas = new SelectList(_context.Xa_GetAll(), "MaXa", "TenXa");
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(KhachHang kh, IFormFile? image)
        {
            // Xử lý upload ảnh (Giống SanPhamController)
            if (image != null && image.Length > 0)
            {
                var uploads = Path.Combine(_env.WebRootPath, "images", "khachhang"); // Lưu vào thư mục images/khachhang
                Directory.CreateDirectory(uploads);

                var fileName = Guid.NewGuid().ToString("N") + Path.GetExtension(image.FileName);
                var path = Path.Combine(uploads, fileName);

                using var fs = new FileStream(path, FileMode.Create);
                await image.CopyToAsync(fs);

                kh.AnhKh = fileName;
            }

            _context.KhachHang_Insert(kh); // Mã KH được sinh tự động trong SQL
            return RedirectToAction(nameof(Index));
        }

        public IActionResult Edit(string id)
        {
            var kh = _context.KhachHang_GetById(id);
            if (kh == null) return NotFound();

            ViewBag.Xas = new SelectList(_context.Xa_GetAll(), "MaXa", "TenXa", kh.MaXa);
            return View(kh);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(KhachHang kh, IFormFile? image, string? existingAnh)
        {
            var uploads = Path.Combine(_env.WebRootPath, "images", "khachhang");
            Directory.CreateDirectory(uploads);

            if (image != null && image.Length > 0)
            {
                // 1. Upload ảnh mới
                var fileName = Guid.NewGuid().ToString("N") + Path.GetExtension(image.FileName);
                var path = Path.Combine(uploads, fileName);
                using var fs = new FileStream(path, FileMode.Create);
                await image.CopyToAsync(fs);

                // 2. Xóa ảnh cũ (nếu có)
                if (!string.IsNullOrEmpty(existingAnh))
                {
                    var oldPath = Path.Combine(uploads, existingAnh);
                    if (System.IO.File.Exists(oldPath)) System.IO.File.Delete(oldPath);
                }
                kh.AnhKh = fileName;
            }
            else
            {
                // Giữ nguyên ảnh cũ
                kh.AnhKh = existingAnh;
            }

            _context.KhachHang_Update(kh);
            return RedirectToAction(nameof(Index));
        }

        public IActionResult Delete(string id)
        {
            var kh = _context.KhachHang_GetById(id);
            return View(kh);
        }

        [HttpPost, ActionName("Delete")]
        public IActionResult DeleteConfirmed(string id)
        {
            var kh = _context.KhachHang_GetById(id);

            // Xóa file ảnh vật lý trước khi xóa dữ liệu
            if (kh != null && !string.IsNullOrEmpty(kh.AnhKh))
            {
                var uploads = Path.Combine(_env.WebRootPath, "images", "khachhang");
                var file = Path.Combine(uploads, kh.AnhKh);
                if (System.IO.File.Exists(file)) System.IO.File.Delete(file);
            }

            _context.KhachHang_Delete(id);
            return RedirectToAction(nameof(Index));
        }

        // GET: KhachHangs/Details/5
        public IActionResult Details(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            // Gọi hàm GetById đã sửa (có map TenXa, TenTinh thủ công)
            var khachHang = _context.KhachHang_GetById(id);

            if (khachHang == null)
            {
                return NotFound();
            }

            return View(khachHang);
        }
    }
}
