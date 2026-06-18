# Hướng Dẫn Tự Động Hóa Báo Cáo Dự Án (Pandoc + GitHub Actions)

Hệ thống này tự động dịch các file Markdown thành tài liệu Word (`.docx`) hoàn chỉnh, vẽ sơ đồ, chèn ảnh từ Google Drive và tải kết quả lên Google Drive của bạn mỗi khi có thay đổi trên nhánh `role/tech-lead`.

## 1. Cấu Trúc Thư Mục

```text
reports/
├── flutter_app/
│   ├── 01_Introduction.md
│   ├── srs/
│   │   ├── srs_intro.md                 <-- Luôn ở đầu mục 02
│   │   ├── 01_auth_profile.md           <-- File tính năng (tự do thêm)
│   │   ├── 02_storefront.md             <-- File tính năng
│   │   ├── ...
│   │   ├── srs_non_functional.md        <-- Luôn ở cuối mục 02
│   │   └── srs_appendix.md              <-- Luôn ở cuối mục 02
│   ├── 03_Software_Design_Description.md
│   └── 04_Software_Testing_Documentation.md
├── diagrams.md            <-- Chứa toàn bộ code Mermaid Diagram
└── SAP341 Project Report.docx <-- Template giao diện gốc của trường
```

## 2. Cách Viết Tài Liệu Tính Năng (SRS)

Bạn có thể tự do tách hoặc thêm các file tính năng trong thư mục `srs/`.
**Quy tắc:** Đặt tên file bắt đầu bằng số (ví dụ: `05_admin_panel.md`). Runner sẽ tự động quét, sắp xếp theo thứ tự bảng chữ cái/số và ghép chúng vào giữa `srs_intro.md` và `srs_non_functional.md`.

## 3. Cách Quản Lý Ảnh Bằng Google Drive

Bạn không cần đẩy ảnh lên GitHub làm nặng repo. Hãy quản lý ảnh mockups trên thư mục Google Drive:

1. **Upload ảnh**: Tải ảnh lên thư mục Drive đã kết nối (ID thư mục đã được đặt trong Secret `GDRIVE_ASSETS_FOLDER_ID`).
2. **Quy tắc đặt tên ảnh trên Drive**: Đặt tên rõ ràng, viết thường, có đuôi mở rộng. Ví dụ: `login_screen.png`, `flow_vnpay.jpg`.
3. **Chèn vào Markdown**:
   Để chèn ảnh từ Drive vào bài viết, hãy sử dụng placeholder sau:
   ```text
   {{IMAGE:login_screen.png}}
   ```
   *Lưu ý: Tên file phải khớp chính xác với tên file bạn đã tải lên Drive (bao gồm cả đuôi mở rộng nếu có).*
   Hệ thống sẽ tự động tải ảnh đó về và chèn thành thẻ `![login_screen.png](...)` vào tài liệu.

## 4. Cách Quản Lý Sơ Đồ Mermaid

Thay vì để code Mermaid rải rác, hãy khai báo tất cả tại file `reports/diagrams.md`.

**Quy tắc khai báo trong `diagrams.md`:**
Mỗi sơ đồ bắt đầu bằng thẻ `## <tên_sơ_đồ>` theo sau là block code mermaid:
```markdown
## flow_vnpay
` ``mermaid
sequenceDiagram
    ...
` ``
```

**Cách chèn sơ đồ vào báo cáo:**
Tại vị trí bạn muốn hiển thị sơ đồ (ví dụ trong file `03_Software_Design_Description.md`), đặt placeholder:
```text
{{DIAGRAM:flow_vnpay}}
```
Hệ thống sẽ tự động gọi API vẽ sơ đồ, lưu thành ảnh và chèn đúng vào vị trí đó!

## 5. Cấu hình GitHub Secrets cần thiết

- `GDRIVE_CREDENTIALS`: Chuỗi JSON Service Account GCP.
- `GDRIVE_FILE_ID`: ID của file Google Docx trống để ghi đè (Cách khắc phục lỗi Quota 0 bytes).
- `GDRIVE_ASSETS_FOLDER_ID`: ID của thư mục Drive chứa ảnh dự án.
