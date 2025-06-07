# Linux Manager

Linux Manager là công cụ quản lý hệ thống Linux mạnh mẽ giúp tự động hóa các tác vụ cài đặt, cấu hình và quản lý hệ thống. Script này đặc biệt hữu ích khi cài đặt hệ điều hành mới, giúp bạn thiết lập môi trường làm việc nhanh chóng và hiệu quả.

## Tính năng chính

- Tự động cài đặt các gói phần mềm thiết yếu (từ kho Pacman và AUR)
- Cấu hình hệ thống theo nhu cầu cá nhân
- Quản lý môi trường phát triển (PHP, Composer, Laravel, NodeJS, Docker)
- Giao diện người dùng dòng lệnh trực quan với các thông báo màu sắc
- Cấu trúc module hóa dễ dàng mở rộng và tùy biến

## Cấu trúc thư mục

```
linux-manager/
├── bin/                 # Scripts khởi chạy chương trình
├── logs/                # Lưu trữ nhật ký hoạt động
├── src/                 # Mã nguồn chính
│   ├── core/            # Các tập tin cốt lõi của ứng dụng
│   ├── data/            # Dữ liệu và cấu hình
│   │   ├── configs/     # Tập tin cấu hình mẫu (bash, fish, vim,...)
│   │   └── packages/    # Danh sách các gói cần cài đặt
│   └── modules/         # Các module chức năng
│       ├── dev/         # Quản lý môi trường phát triển
│       │   ├── docker/  # Module quản lý Docker
│       │   ├── nodejs/  # Module quản lý NodeJS/NPM
│       │   └── php/     # Module quản lý PHP/Composer/Laravel
│       ├── misc/        # Các tiện ích khác
│       ├── packages/    # Quản lý cài đặt gói
│       └── system/      # Quản lý cấu hình hệ thống
├── config.sh            # Cấu hình chung (danh sách gói cài đặt)
├── install.sh           # Script cài đặt ứng dụng
├── setup.sh             # Script thiết lập cấu trúc thư mục
└── uninstall.sh         # Script gỡ cài đặt ứng dụng
```

## Luồng hoạt động của ứng dụng

```mermaid
graph TB
    A[Người dùng] -->|Chạy| B[install.sh]
    B -->|Tạo cấu trúc thư mục| C[setup.sh]
    C -->|Tạo cấu hình core| D[src/core/config.sh]

    A -->|Sử dụng| E[bin/linux-manager]
    E -->|Hiển thị menu| F[Menu chính]

    F -->|Chọn| G1[Cài đặt gói]
    F -->|Chọn| G2[Cấu hình hệ thống]
    F -->|Chọn| G3[Quản lý PHP/Composer]
    F -->|Chọn| G4[Quản lý NodeJS/NPM]
    F -->|Chọn| G5[Quản lý Docker]

    G1 -->|Đọc danh sách| H1[src/data/packages/*.list]
    G1 -->|Cài đặt| I1[Pacman/AUR/Flatpak]

    G2 -->|Đọc cấu hình| H2[src/data/configs/*]
    G2 -->|Áp dụng cấu hình| I2[Các tập tin hệ thống]

    G3 -->|Cài đặt/Cấu hình| I3[PHP/Composer/Laravel]
    G4 -->|Cài đặt/Cấu hình| I4[NVM/NodeJS/NPM]
    G5 -->|Cài đặt/Cấu hình| I5[Docker/Docker Compose]

    A -->|Gỡ cài đặt| J[uninstall.sh]
    J -->|Xóa thư mục| K[Xóa dữ liệu]
```

## Hướng dẫn cài đặt

### Yêu cầu hệ thống

- Hệ điều hành dựa trên Arch Linux (Arch, Manjaro, EndeavourOS, CachyOS,...)
- Bash shell
- Quyền sudo

### Các bước cài đặt

1. Tải về mã nguồn:

```bash
git clone https://github.com/mttk2004/linux-manager.git
cd linux-manager
```

2. Cấp quyền thực thi cho script cài đặt:

```bash
chmod +x install.sh
```

3. Chạy script cài đặt:

```bash
./install.sh
```

Script sẽ tự động tạo cấu trúc thư mục cần thiết và chuẩn bị các tập tin cấu hình.

## Cách sử dụng

Sau khi cài đặt, bạn có thể chạy Linux Manager bằng lệnh:

```bash
./bin/linux-manager
```

Hoặc tạo liên kết tượng trưng để chạy từ bất kỳ đâu:

```bash
sudo ln -s /path/to/linux-manager/bin/linux-manager /usr/local/bin/linux-manager
```

Khi chạy, chương trình sẽ hiển thị menu chính với các tùy chọn:

1. **Cài đặt gói phần mềm** - Cài đặt các gói từ kho Pacman và AUR
2. **Cấu hình hệ thống** - Thiết lập cấu hình cho shell, terminal, và các ứng dụng
3. **Quản lý PHP/Composer/Laravel** - Cài đặt và cấu hình môi trường PHP
4. **Quản lý NVM/NodeJS/NPM** - Cài đặt và cấu hình môi trường NodeJS
5. **Quản lý Docker** - Cài đặt và cấu hình Docker và Docker Compose

## Tùy chỉnh

### Thêm gói cài đặt

Bạn có thể chỉnh sửa danh sách gói trong các tập tin:
- `src/data/packages/pacman.list` - Gói từ kho chính thức
- `src/data/packages/aur.list` - Gói từ AUR

Hoặc chỉnh sửa trực tiếp trong `config.sh`

### Thêm cấu hình riêng

Bạn có thể thêm cấu hình shell, terminal hoặc trình soạn thảo vào thư mục `src/data/configs/`.

### Thêm module mới

Để thêm một module mới:
1. Tạo thư mục mới trong `src/modules/`
2. Tạo tập tin `manager.sh` trong thư mục module
3. Triển khai các hàm cần thiết
4. Cập nhật script chính để tích hợp module mới

## Gỡ cài đặt

Để gỡ cài đặt Linux Manager, chạy:

```bash
./uninstall.sh
```

Script sẽ xóa tất cả dữ liệu liên quan đến Linux Manager nhưng vẫn giữ lại các tập tin gốc để bạn có thể cài đặt lại sau này.

## Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo pull request hoặc báo cáo lỗi nếu bạn tìm thấy vấn đề.

## Giấy phép

Phần mềm này được phân phối theo giấy phép MIT.
