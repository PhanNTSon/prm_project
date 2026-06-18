# Hướng Dẫn Tự Động Hóa Báo Cáo Dự Án (Pandoc + GitHub Actions)

Hệ thống này tự động dịch các file Markdown thành tài liệu Word (`.docx`) hoàn chỉnh, tự vẽ sơ đồ Mermaid, chèn ảnh mockup từ Google Drive và tải kết quả lên chính Google Drive của bạn mỗi khi có thay đổi trên nhánh `role/tech-lead`.

---

## 1. Cấu Trúc Thư Mục Báo Cáo

Hệ thống quản lý báo cáo được tổ chức linh hoạt:

```text
reports/
├── flutter_app/
│   ├── 01_Introduction.md               <-- Chương I
│   ├── srs/                             <-- Chương II (Đặc tả yêu cầu)
│   │   ├── srs_intro.md                 <-- Phần mở đầu chương II (Cố định ở đầu)
│   │   ├── 01_auth_profile.md           <-- Các file tính năng (Đánh số thứ tự)
│   │   ├── 02_storefront.md
│   │   ├── ...                          <-- Team có thể tự tạo thêm file tại đây
│   │   ├── srs_non_functional.md        <-- Yêu cầu NFR (Cố định ở cuối)
│   │   └── srs_appendix.md              <-- Phụ lục (Cố định ở cuối)
│   ├── 03_Software_Design_Description.md <-- Chương III
│   └── 04_Software_Testing_Documentation.md <-- Chương IV
├── diagrams.md                          <-- Chứa TẤT CẢ code sơ đồ Mermaid của dự án
└── SAP341 Project Report.docx           <-- Template giao diện gốc của trường
```

> **Nguyên tắc "Lắp ghép" tự động:**
> Bạn có thể tự do tách hoặc thêm các file tính năng trong thư mục `srs/`. Chỉ cần đặt tên file bắt đầu bằng số (ví dụ: `05_admin_panel.md`). Runner sẽ tự động quét, sắp xếp theo thứ tự và gộp tất cả chúng vào giữa phần Mở đầu (`srs_intro.md`) và Phụ lục (`srs_appendix.md`) mà không cần bạn phải chỉnh sửa cấu hình ở đâu khác!

---

## 2. Quản Lý Hình Ảnh (Mockups/Assets) Bằng Google Drive

Để tránh làm nặng repository GitHub bằng các tệp nhị phân, hãy quản lý toàn bộ ảnh trên Google Drive của nhóm.

1. **Chuẩn bị Thư mục Drive**: Tạo một thư mục trên Google Drive (ví dụ: `Mockups Dự Án`), cấp quyền **Viewer** cho email Service Account.
2. **Cấu hình Secret**: Lấy ID của thư mục đó và dán vào GitHub Secret mang tên `GDRIVE_ASSETS_FOLDER_ID`.
3. **Quy tắc tải ảnh**: Đặt tên ảnh rõ ràng, không dấu (VD: `login_screen.png`, `flow_vnpay.jpg`) và tải lên thư mục Drive đó.
4. **Cách chèn ảnh vào Markdown**: Tại vị trí cần chèn trong tài liệu, sử dụng cú pháp Placeholder:
   ```text
   {{IMAGE:login_screen.png}}
   ```
   **Cơ chế hoạt động**: Khi chạy CI/CD, hệ thống tự động tải `login_screen.png` từ thư mục Drive về và thay thế Placeholder thành thẻ ảnh Markdown thực thụ, sau đó nhúng trực tiếp vào file Word.

---

## 3. Quản Lý Sơ Đồ Hệ Thống (Mermaid Diagrams)

Toàn bộ sơ đồ hệ thống được quản lý tập trung tại file `reports/diagrams.md`.

**Cách khai báo một sơ đồ mới:**
Mở file `diagrams.md`, khai báo tên sơ đồ bằng thẻ H2 (`##`), theo ngay sau đó là block code Mermaid:
```markdown
## payment_flow
` ``mermaid
sequenceDiagram
    Client->>VNPay: Request payment
    ...
` ``
```
*(Lưu ý: Mermaid dùng `-->` hoặc `->>` để làm mũi tên, KHÔNG DÙNG `--->` sẽ gây lỗi cú pháp 404)*

**Cách chèn sơ đồ vào báo cáo:**
Tại bất kỳ file Markdown báo cáo nào (ví dụ `03_Software_Design_Description.md`), chèn cú pháp:
```text
{{DIAGRAM:payment_flow}}
```
Hệ thống sẽ tự động gọi API vẽ sơ đồ, xuất ra ảnh chất lượng cao và nhúng vào vị trí bạn yêu cầu.

---

## 4. Danh Sách GitHub Secrets Bắt Buộc

Để workflow hoạt động trơn tru, bạn cần cài đặt đủ 3 Secrets trong kho lưu trữ GitHub:

- `GDRIVE_CREDENTIALS`: Nội dung file JSON chứa khóa của GCP Service Account (Dùng để xác thực API Google Drive).
- `GDRIVE_FILE_ID`: ID của tệp tin Word `.docx` rỗng có sẵn trên Drive mà bạn là chủ sở hữu (Khắc phục lỗi Quota 0 bytes của Service Account). Tài liệu sẽ được ghi đè liên tục vào file này.
- `GDRIVE_ASSETS_FOLDER_ID`: ID của thư mục Drive chứa ảnh dự án để chèn vào báo cáo.
