import SwiftUI

struct CloudStoragePlan: Identifiable {
    let id = UUID()
    let name: String
    let storage: String
    let price: Double
    let priceFormatted: String
}

struct CloudStorageAppView: View {
    // Danh sách các gói lưu trữ đám mây
    let plans = [
        CloudStoragePlan(name: "Gói Cơ Bản", storage: "50 GB", price: 19000, priceFormatted: "19.000 đ / tháng"),
        CloudStoragePlan(name: "Gói Tiêu Chuẩn", storage: "200 GB", price: 49000, priceFormatted: "49.000 đ / tháng"),
        CloudStoragePlan(name: "Gói Cao Cấp", storage: "2 TB", price: 199000, priceFormatted: "199.000 đ / tháng")
    ]
    
    @State private var selectedPlan: CloudStoragePlan?
    @State private var showingPayment = false
    @State private var isUpgraded = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header thông tin dung lượng hiện tại
                VStack(spacing: 8) {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Cloud Storage của bạn")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(isUpgraded ? "Đã nâng cấp dung lượng cao" : "Dung lượng miễn phí: 5 GB / 15 GB")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Trạng thái tài khoản
                if isUpgraded {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Tài khoản đang hoạt động trả phí")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Danh sách gói cước
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
                    PaymentView(plan: plan, isUpgraded: $isUpgraded)
                }
            }
        }
    }
}

// Màn hình hiển thị thông tin thanh toán QR
struct PaymentView: View {
    let plan: CloudStoragePlan
    @Binding var isUpgraded: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Thanh toán dịch vụ")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Gói đăng ký: **\(plan.name)** (\(plan.storage))")
                Text("Số tiền cần chuyển: **\(plan.priceFormatted)**")
                Text("Chủ tài khoản: **HOANG HAI AN**[span_1](start_span)[span_1](end_span)")
                Text("Số tài khoản MB: **0030132291981**[span_2](start_span)[span_2](end_span)")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Khu vực hiển thị mã QR (Sử dụng hình ảnh QR VietQR MBBank từ nguồn đính kèm)
            VStack(spacing: 8) {
                // Ở đây bạn có thể thay thế bằng Image("ten_anh_qr") nếu đã add vào Assets
                // Hoặc hiển thị placeholder/hình ảnh quét mã VietQR MBBank
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                
                Text("Quét mã QR qua ứng dụng Ngân hàng (MB Bank / VietQR)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Nút xác nhận sau khi chuyển khoản thành công
            Button(action: {
                // Giả lập xác nhận thanh toán thành công
                isUpgraded = true
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Tôi đã chuyển khoản thành công")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

struct CloudStorageAppView_Previews: PreviewProvider {
    static var previews: some View {
        CloudStorageAppView()
    }
}
