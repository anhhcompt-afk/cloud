import streamlit as st
import uuid

# Cấu hình trang Streamlit
st.set_page_config(
    page_title="Cloud Infrastructure Billing",
    page_icon="☁️",
    layout="centered"
)

# Thông tin tài khoản thanh toán
BANK_INFO = {
    "bank_id": "MB",
    "account_no": "0030132291981",
    "account_name": "HOANG HAI AN",
    "admin_phone": "0964058714",
    "admin_email": "anhh.compt@gmail.com"
}

# Khởi tạo Session State để lưu trữ dữ liệu giả lập trong bộ nhớ phiên làm việc
if "orders" not in st.session_state:
    st.session_state.orders = {}
if "instances" not in st.session_state:
    st.session_state.instances = {}

st.title("☁️ Hệ Thống Cung Cấp Hạ Tầng Cloud")
st.write("Đăng ký thuê máy chủ ảo và thanh toán tự động qua mã VietQR.")

# Menu lựa chọn giao diện: Khách hàng hay Admin
menu = st.sidebar.selectbox("Chọn chế độ giao diện", ["🛒 Khách hàng (Mua Cloud)", "🔐 Quản trị viên (Admin Approve)"])

# ==================== GIAO DIỆN KHÁCH HÀNG ====================
if menu == "🛒 Khách hàng (Mua Cloud)":
    st.header("1. Chọn gói cước Cloud / VPS")
    
    # Bảng giá gói cước mẫu
    plans = {
        "Gói Basic (1 vCPU / 2GB RAM / 30GB SSD)": 100000,
        "Gói Standard (2 vCPU / 4GB RAM / 50GB SSD)": 200000,
        "Gói Pro (4 vCPU / 8GB RAM / 100GB SSD)": 400000
    }
    
    selected_plan = st.selectbox("Chọn cấu hình máy chủ:", list(plans.keys()))
    price = plans[selected_plan]
    
    st.info(f"💰 Giá cước: **{price:,} VNĐ / tháng**")
    
    customer_email = st.text_input("Nhập Email của bạn (để nhận Key kích hoạt):")
    
    if st.button("Tạo đơn hàng & Lấy mã QR thanh toán"):
        if not customer_email:
            st.error("Vui lòng nhập email để tiếp tục!")
        else:
            order_id = str(uuid.uuid4())[:6].upper()
            transfer_content = f"CLOUD {order_id}"
            
            # Tạo URL QR VietQR chuẩn
            qr_url = (
                f"https://img.vietqr.io/image/{BANK_INFO['bank_id']}-{BANK_INFO['account_no']}-compact2.png"
                f"?amount={price}&addInfo={transfer_content}&accountName={BANK_INFO['account_name']}"
            )
            
            # Lưu đơn hàng vào session state
            st.session_state.orders[order_id] = {
                "order_id": order_id,
                "email": customer_email,
                "plan": selected_plan,
                "amount": price,
                "status": "PENDING",
                "transfer_content": transfer_content
            }
            
            st.success(f"Tạo đơn hàng thành công! Mã đơn hàng: **{order_id}**")
            
    # Hiển thị thông tin thanh toán nếu có đơn hàng gần nhất
    if st.session_state.orders:
        st.divider()
        st.subheader("📌 Thông Tin Thanh Toán Chuyển Khoản")
        
        # Lấy đơn hàng mới nhất của phiên
        latest_order_id = list(st.session_state.orders.keys())[-1]
        order = st.session_state.orders[latest_order_id]
        
        col1, col2 = st.columns(2)
        with col1:
            st.write(f"- **Mã đơn hàng:** `{order['order_id']}`")
            st.write(f"- **Ngân hàng:** `{BANK_INFO['bank_id']}`")
            st.write(f"- **Số tài khoản:** `{BANK_INFO['account_no']}`")[span_1](start_span)[span_1](end_span)
            st.write(f"- **Chủ tài khoản:** `{BANK_INFO['account_name']}`")[span_2](start_span)[span_2](end_span)
            st.write(f"- **Số tiền:** `{order['amount']:,} VNĐ`")
            st.write(f"- **Nội dung chuyển khoản:** `{order['transfer_content']}`")
            st.markdown(f"**Trạng thái đơn:** `{order['status']}`")
            
            if order['status'] == 'ACTIVE':
                st.success(f"🎉 Máy chủ của bạn đã hoạt động! Key: `{order.get('cloud_key', 'N/A')}`")
        
        with col2:
            st.image(
                f"https://img.vietqr.io/image/{BANK_INFO['bank_id']}-{BANK_INFO['account_no']}-compact2.png?amount={order['amount']}&addInfo={order['transfer_content']}&accountName={BANK_INFO['account_name']}",
                caption="Quét mã QR bằng App Ngân Hàng",
                width=250
            )
            
        st.warning(f"⚠️ **Lưu ý:** Sau khi chuyển khoản thành công, vui lòng nhắn tin qua SĐT/Zalo **{BANK_INFO['admin_phone']}** hoặc gửi email về **{BANK_INFO['admin_email']}** kèm mã đơn hàng `{order['order_id']}` để được anh duyệt cấp key nhanh chóng!")

# ==================== GIAO DIỆN ADMIN ====================
elif menu == "🔐 Quản trị viên (Admin Approve)":
    st.header("🔐 Trang Quản Trị Hệ Thống (Dành cho Anh)")
    
    admin_pass = st.text_input("Nhập mật khẩu Admin:", type="password")
    
    # Mật khẩu mẫu định sẵn cho anh (có thể đổi tùy ý)
    if admin_pass == "123456":
        st.success("Đăng nhập Admin thành công!")
        
        st.subheader("Danh sách đơn hàng hiện có:")
        if not st.session_state.orders:
            st.info("Chưa có đơn hàng nào được tạo.")
        else:
            for oid, ord_data in st.session_state.orders.items():
                st.write(f"---")
                st.write(f"**Mã đơn:** `{oid}` | **Email:** {ord_data['email']} | **Gói:** {ord_data['plan']} | **Số tiền:** {ord_data['amount']:,}đ | **Trạng thái:** `{ord_data['status']}`")
                
                if ord_data['status'] == "PENDING":
                    if st.button(f"Approve & Cấp Key cho đơn {oid}", key=f"btn_{oid}"):
                        # Cập nhật trạng thái
                        ord_data['status'] = "ACTIVE"
                        cloud_key = "CLOUD-KEY-" + str(uuid.uuid4()).upper()[:8]
                        ord_data['cloud_key'] = cloud_key
                        st.success(f"Đã duyệt đơn {oid} thành công! Khóa Cloud được tạo: {cloud_key}")
                        st.rerun()
                else:
                    st.info(f"Đã kích hoạt. Key: `{ord_data.get('cloud_key')}`")
    elif admin_pass != "":
        st.error("Sai mật khẩu Admin! (Mật khẩu mặc định trong code mẫu là: 123456)")
