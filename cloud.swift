import SwiftUI

struct CloudStoragePlan: Identifiable {
    let id = UUID()
    let name: String
    let storage: String
    let priceFormatted: String
}

struct CloudStorageAppView: View {
    let plans = [
        CloudStoragePlan(name: "Gói Cơ Bản", storage: "50 GB", priceFormatted: "19.000 đ / tháng"),
        CloudStoragePlan(name: "Gói Tiêu Chuẩn", storage: "200 GB", priceFormatted: "49.000 đ / tháng"),
        CloudStoragePlan(name: "Gói Cao Cấp", storage: "2 TB", priceFormatted: "199.000 đ / tháng")
    ]
    
    @State private var selectedPlan: CloudStoragePlan?
    @State private var showingPayment = false
    @State private var showingKeyInput = false
    @State private var isUpgraded = false
    @State private var currentPlanName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Dung Lượng
                VStack(spacing: 8) {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Cloud Storage của bạn")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isUpgraded ? "Đang dùng: \(currentPlanName)" : "Dung lượng miễn phí: 5 GB / 15 GB")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                if isUpgraded {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Tài khoản đã kích hoạt trả phí")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Nút nhập Key kích hoạt trực tiếp nếu khách đã có key
                Button(action: {
                    showingKeyInput = true
                }) {
                    HStack {
                        Image(systemName: "key.fill")
                        Text("Bạn đã có Key kích hoạt? Nhập tại đây")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.top, 5)

                // Danh sách gói
                List(plans) { plan in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.name)
                                .font(.headline)
                            Text("Dung lượng: \(plan.storage)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(plan.priceFormatted)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Button(action: {
                                selectedPlan = plan
                                showingPayment = true
                            }) {
                                Text("Nâng cấp")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Đám Mây Việt")
            .sheet(isPresented: $showingPayment) {
                if let plan = selectedPlan {
                    PaymentView(plan: plan, onActivateSuccess: { planName in
                        self.isUpgraded = true
                        self.currentPlanName = planName
                    })
                }
            }
            .sheet(isPresented: $showingKeyInput) {
                KeyActivationView(onSuccess: {
                    self.isUpgraded = true
                    self.currentPlanName = "Gói Trả Phí"
                })
            }
        }
    }
}

// Màn hình Thanh toán & Hướng dẫn gửi Xác nhận
struct PaymentView: View {
    let plan: CloudStoragePlan
    var onActivateSuccess: (String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var copiedField: String?
    @State private var showKeyScreen = false
    
    // Thông tin liên hệ của Anh
    let adminPhone = "0964058714"
    let adminEmail = "anhh.compt@gmail.com"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Bước 1: Thông tin chuyển khoản
                    VStack(alignment: .leading, spacing: 12) {
                        Text(" BƯỚC 1: CHUYỂN KHOẢN")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        InfoRow(title: "Ngân hàng", value: "MB Bank")
                        Divider()
                        InfoRow(title: "Chủ tài khoản", value: "HOANG HAI AN")[span_1](start_span)[span_1](end_span)
                        Divider()
                        InfoRow(title: "Số tài khoản", value: "0030132291981", canCopy: true) {[span_2](start_span)[span_2](end_span)
                            UIPasteboard.general.string = "0030132291981[span_3](start_span)"[span_3](end_span)
                            copiedField = "Số tài khoản"
                        }
                        Divider()
                        InfoRow(title: "Số tiền", value: plan.priceFormatted)
                        Divider()
                        InfoRow(title: "Nội dung CK", value: "CLOUD \(plan.name.uppercased())", canCopy: true) {
                            UIPasteboard.general.string = "CLOUD \(plan.name.uppercased())"
                            copiedField = "Nội dung"
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if let copiedField = copiedField {
                        Text("Đã sao chép: \(copiedField)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    // Bước 2: Gửi thông báo cho Admin
                    VStack(alignment: .leading, spacing: 12) {
                        Text(" BƯỚC 2: GỬI BILL XÁC NHẬN")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text("Sau khi chuyển khoản, vui lòng gửi ảnh chụp màn hình bill cho Admin để nhận Mã kích hoạt (Key):")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            // Nút nhắn tin Zalo / SMS
                            Button(action: openSMS) {
                                HStack {
                                    Image(systemName: "message.fill")
                                    Text("Gửi SMS/Zalo")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            // Nút gửi Email
                            Button(action: openEmail) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("Gửi Email")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer(minLength: 20)
                    
                    // Nút nhập Key sau khi Admin duyệt
                    Button(action: {
                        showKeyScreen = true
                    }) {
                        Text("Tôi đã nhận Key & Muốn Kích Hoạt")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Thanh Toán")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showKeyScreen) {
                KeyActivationView(onSuccess: {
                    onActivateSuccess(plan.name)
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
    
    // Mở ứng dụng tin nhắn SMS
    func openSMS() {
        let body = "Toi da chuyen khoan goi \(plan.name). Vui long gui Key kich hoat."
        if let url = URL(string: "sms:\(adminPhone)&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    // Mở ứng dụng Mail
    func openEmail() {
        let subject = "Xac nhan thanh toan Cloud - \(plan.name)"
        let body = "Chao Admin, toi da chuyen khoan goi \(plan.name). Dinh kem bill thanh toan."
        if let url = URL(string: "mailto:\(adminEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
}

// Màn hình nhập Key do Admin cung cấp
struct KeyActivationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var activationKey = ""
    @State private var errorMessage = ""
    var onSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Nhập Mã Kích Hoạt")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Nhập mã (Key) bạn nhận được từ Admin qua Zalo hoặc Email để kích hoạt dịch vụ.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Nhập mã Key (Ví dụ: CLOUD-1234)", text: $activationKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: verifyKey) {
                Text("Xác Nhận Kích Hoạt")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    func verifyKey() {
        // Kiểm tra Key (Ví dụ mẫu: Key chấp nhận là VIP2026 hoặc CLOUD123)
        if activationKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Vui lòng nhập mã Key"
        } else {
            // Giả lập xác thực Key đúng
            onSuccess()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var canCopy: Bool = false
    var onCopy: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
            
            if canCopy {
                Button(action: { onCopy?() }) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
