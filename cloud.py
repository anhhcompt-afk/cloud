from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel
import uuid
from typing import Optional

app = FastAPI(
    title="Cloud Infrastructure - Manual Approval Billing",
    description="Hệ thống cloud thanh toán qua VietQR và duyệt thủ công bởi Admin",
    version="1.1.0"
)

# Thông tin tài khoản ngân hàng nhận tiền
BANK_INFO = {
    "bank_id": "MB",
    "account_no": "0030132291981",
    "account_name": "HOANG HAI AN",
    "admin_phone": "0964058714",
    "admin_email": "anhh.compt@gmail.com"
}

# Database giả lập
orders_db = {}
licenses_db = {}

class OrderRequest(BaseModel):
    plan_name: str
    amount: int
    customer_email: str
    customer_phone: Optional[str] = None

class AdminApproveRequest(BaseModel):
    order_id: str
    admin_secret_key: str  # Khóa bảo mật dành riêng cho anh để duyệt đơn

@app.get("/")
def home():
    return {
        "message": "Hệ thống Cloud Infrastructure đang hoạt động.",
        "bank_info": BANK_INFO
    }

# 1. Khách hàng tạo đơn hàng
@app.post("/api/order/create")
def create_order(data: OrderRequest):
    order_id = str(uuid.uuid4())[:6].upper()
    transfer_content = f"CLOUD {order_id}"
    
    # Tạo link mã VietQR tự động điền sẵn số tiền và nội dung
    qr_url = (
        f"https://img.vietqr.io/image/{BANK_INFO['bank_id']}-{BANK_INFO['account_no']}-compact2.png"
        f"?amount={data.amount}&addInfo={transfer_content}&accountName={BANK_INFO['account_name']}"
    )

    order = {
        "order_id": order_id,
        "customer_email": data.customer_email,
        "customer_phone": data.customer_phone,
        "plan_name": data.plan_name,
        "amount": data.amount,
        "status": "PENDING_PAYMENT", # Chờ khách chuyển khoản
        "payment_info": {
            "bank": BANK_INFO["bank_id"],
            "account_no": BANK_INFO["account_no"],
            "account_name": BANK_INFO["account_name"],
            "transfer_content": transfer_content,
            "qr_code_url": qr_url,
            "instruction": f"Sau khi chuyển khoản, vui lòng nhắn tin tới SĐT {BANK_INFO['admin_phone']} hoặc email {BANK_INFO['admin_email']} kèm mã đơn hàng {order_id}."
        }
    }
    
    orders_db[order_id] = order
    return {
        "message": "Tạo đơn hàng thành công. Vui lòng quét mã QR thanh toán và liên hệ Admin.",
        "order": order
    }

# 2. Admin duyệt đơn hàng (Sau khi thấy tiền về tài khoản MB)
@app.post("/api/admin/approve")
def admin_approve_order(data: AdminApproveRequest):
    # Bảo mật đơn giản cho Admin (có thể đổi key này theo ý anh)
    if data.admin_secret_key != "ANHH_SECURE_ADMIN_2026":
        raise HTTPException(status_code=403, detail="Sai khóa bảo mật Admin!")
    
    if data.order_id not in orders_db:
        raise HTTPException(status_code=404, detail="Không tìm thấy mã đơn hàng.")
    
    order = orders_db[data.order_id]
    if order["status"] == "ACTIVE":
        return {"message": "Đơn hàng này đã được kích hoạt trước đó rồi."}
    
    # Cập nhật trạng thái đơn hàng
    order["status"] = "ACTIVE"
    
    # Sinh Cloud Key / License Key cho khách
    cloud_key = "CLOUD-KEY-" + str(uuid.uuid4()).upper()
    licenses_db[data.order_id] = {
        "customer_email": order["customer_email"],
        "plan_name": order["plan_name"],
        "cloud_key": cloud_key,
        "status": "RUNNING"
    }
    
    # (Ở đây hệ thống có thể tích hợp code gửi email tự động tới khách hàng chứa `cloud_key`)
    
    return {
        "message": f"Đã duyệt đơn hàng {data.order_id} thành công!",
        "customer_email": order["customer_email"],
        "generated_cloud_key": cloud_key
    }

# 3. Khách hàng kiểm tra trạng thái đơn hàng / Key của mình
@app.get("/api/order/status/{order_id}")
def check_order_status(order_id: str):
    if order_id not in orders_db:
        raise HTTPException(status_code=404, detail="Mã đơn hàng không tồn tại.")
    
    order = orders_db[order_id]
    result = {
        "order_id": order_id,
        "status": order["status"],
        "plan_name": order["plan_name"]
    }
    if order["status"] == "ACTIVE":
        result["cloud_key"] = licenses_db[order_id]["cloud_key"]
        
    return result
