# 📊 Báo Cáo Dự Án Centurion Store (Flutter Mobile App)

Thư mục này chứa toàn bộ tài nguyên báo cáo dự án bao gồm tài liệu yêu cầu (RDS/SRS), mô tả thiết kế (SDD), kế hoạch kiểm thử (STD), và file báo cáo `.docx` gốc được sử dụng làm mẫu (template).

---

## 1. Cấu Trúc Thư Mục
```text
reports/
├── flutter_app/            # Các phần báo cáo đã được chia nhỏ theo template mới
│   ├── 01_Introduction.md  # Phần I: Project Introduction & Definitions
│   ├── 02_Software_Requirement_Specification.md  # Phần II: SRS & Functional Specs
│   ├── 03_Software_Design_Description.md         # Phần III: SDD & Package Diagram
│   └── 04_Software_Testing_Documentation.md      # Phần IV: STD & Test Reports
│
├── SAP341 Project Report.docx  # Báo cáo gốc làm mẫu (Reference Doc)
├── Report Template.docx.md     # Cấu trúc Template chuẩn dưới dạng Markdown
├── RDS_CenturionStore.docx.md  # Báo cáo RDS cũ (phiên bản Web)
├── SRS_CenturionStore.docx.md  # Báo cáo SRS cũ (phiên bản Web)
└── README.md                   # Hướng dẫn này
```

---

## 2. Tự Động Hóa Tạo Báo Cáo `.docx` Bằng Pandoc

### A. Tự động hóa qua GitHub Actions
Một workflow đã được thiết lập tại `.github/workflows/generate_report.yml`. Mỗi khi bạn thực hiện `push` thay đổi vào thư mục `reports/flutter_app/` hoặc kích hoạt thủ công (`workflow_dispatch`), GitHub Actions sẽ tự động:
1. Sử dụng **Pandoc** biên dịch các file Markdown trong `reports/flutter_app/` thành file Word `SAP341_Project_Report_Generated.docx`.
2. Sử dụng file `reports/SAP341 Project Report.docx` làm **tài liệu mẫu định dạng** (Reference Doc) để áp dụng các style (Font, Margin, Paragraph, Header) của trường FPT.
3. Tự động đẩy file được tạo lên **Google Drive** của nhóm thông qua Service Account credentials đã cấu hình trong GitHub Secrets.

#### Cách Cấu Hình GitHub Secrets:
1. `GDRIVE_CREDENTIALS`: Nội dung file JSON Private Key của Google Service Account (hoặc dạng mã hóa Base64).
2. `GDRIVE_FOLDER_ID` (Không bắt buộc): ID thư mục Google Drive của nhóm nơi bạn muốn lưu trữ file.

---

### B. Chạy Thủ Công Trên Máy Cá Nhân (Local)
Nếu máy bạn đã cài đặt **Pandoc**, chạy lệnh sau tại thư mục gốc của dự án để xuất ra file docx:

```bash
pandoc --reference-doc="reports/SAP341 Project Report.docx" \
  reports/flutter_app/01_Introduction.md \
  reports/flutter_app/02_Software_Requirement_Specification.md \
  reports/flutter_app/03_Software_Design_Description.md \
  reports/flutter_app/04_Software_Testing_Documentation.md \
  -o reports/SAP341_Project_Report_Generated.docx
```
