# PTTKPM-Nhom13
Xây dựng hệ thống quản lý thư viện

**1. Mô tả khái quát về nội dung đề tài**
Đề tài xây dựng ứng dụng quản lý thư viện bằng Flutter nhằm hiện đại hóa hoạt động quản lý và cải thiện trải nghiệm người dùng. Ứng dụng sẽ hỗ trợ quản lý sách, tài liệu, người dùng, và quá trình mượn/trả sách thông qua giao diện trực quan và tương tác cao. Với Flutter, ứng dụng có thể chạy đồng thời trên Android và iOS, giúp tiết kiệm chi phí phát triển và mở rộng khả năng tiếp cận.

Ứng dụng hướng đến việc đơn giản hóa các nghiệp vụ của thư viện, hỗ trợ quản trị viên, nhân viên thư viện và cả độc giả, đồng thời cung cấp các báo cáo và thống kê để tối ưu hóa quy trình vận hành thư viện.

**2. Mô tả các yêu cầu tổ chức chương trình chính**
a) Về công nghệ:
Framework phát triển giao diện: Flutter.
Ngôn ngữ lập trình: Dart.
Cơ sở dữ liệu: Firebase Firestore hoặc SQLite (tùy nhu cầu).
Xác thực và bảo mật: Firebase Authentication (hỗ trợ email, Google, hoặc tài khoản cá nhân).
API backend: RESTful API hoặc Firebase Cloud Functions nếu sử dụng Firebase.
State management: Provider, Riverpod hoặc Bloc (quản lý trạng thái trong ứng dụng).
b) Về chức năng chính:
Đối với Quản trị viên:

Quản lý sách và tài liệu:
Thêm, sửa, xóa, và phân loại sách.
Quản lý trạng thái sách (đã mượn, còn sẵn có).
Quản lý người dùng:
Thêm, xóa tài khoản nhân viên thư viện và độc giả.
Phân quyền truy cập (quản trị viên, nhân viên).
Xem báo cáo, thống kê:
Thống kê số lượng sách trong thư viện, số lượng sách đang được mượn, và sách bị quá hạn.
Đối với Nhân viên thư viện:

Thực hiện quy trình mượn/trả sách:
Tra cứu thông tin độc giả và sách mượn.
Cập nhật trạng thái mượn/trả.
Hỗ trợ tìm kiếm sách theo danh mục, tác giả, hoặc mã ISBN.
Đối với Độc giả:

Tra cứu thông tin sách (tên, tác giả, tình trạng còn sẵn).
Theo dõi lịch sử mượn sách, trạng thái sách hiện tại.
Nhận thông báo nhắc nhở trả sách (qua ứng dụng hoặc email).
Tính năng bổ sung:

Tích hợp quét mã QR/mã vạch sách để tối ưu hóa quy trình tra cứu và mượn sách.
Tích hợp chế độ offline (cho phép truy cập dữ liệu cơ bản khi không có mạng).
**3. Mô tả về tính sử dụng, áp dụng, các thành phần người dùng**
a) Tính sử dụng:
Ứng dụng dễ sử dụng, giao diện thân thiện, trực quan.
Hỗ trợ cả thiết bị Android và iOS với hiệu năng ổn định nhờ Flutter.
Đáp ứng tốt nhu cầu của cả thư viện nhỏ lẫn các thư viện lớn.
b) Các thành phần người dùng:
Quản trị viên:
Theo dõi và quản lý toàn bộ hệ thống, đảm bảo hoạt động thư viện trơn tru.
Nhân viên thư viện:
Quản lý mượn/trả sách và hỗ trợ người dùng tìm kiếm thông tin.
Độc giả:
Dễ dàng tra cứu thông tin và theo dõi các khoản mượn cá nhân qua ứng dụng.
**4. Mô tả sơ về kết quả dự kiến/mong muốn**
Kết quả dự kiến:
Hoàn thiện ứng dụng Flutter với đầy đủ chức năng cho từng nhóm người dùng.
Tối ưu hóa thời gian quản lý:
Hệ thống quản lý tự động và chính xác.
Thống kê chi tiết:
Cung cấp các số liệu như số sách đã mượn, sách còn sẵn, số độc giả.
Cải thiện trải nghiệm người dùng:
Giao diện thân thiện, tính năng thông báo trả sách giúp người dùng tránh bị phạt.
Mong muốn:
Ứng dụng được triển khai thành công và hoạt động ổn định trên nhiều thiết bị.
Dễ dàng bảo trì và mở rộng để thêm các chức năng nâng cao như tích hợp AI gợi ý sách.






