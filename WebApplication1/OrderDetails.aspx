<%@ Page Title="Order Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderDetails.aspx.cs" Inherits="WebApplication1.OrderDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="container-fluid my-4">
        <div class="row justify-content-center">
            <div class="col-xl-10">
                <!-- Header -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="text-primary fw-bold mb-1">Order Details</h2>
                        <p class="text-muted mb-0">Complete order information and tracking</p>
                    </div>
                    <asp:Button ID="btnBack" runat="server" Text="? Back" CssClass="btn btn-outline-secondary px-4" OnClick="btnBack_Click" />
                </div>

                <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger border-0 shadow-sm" Visible="false"></asp:Label>

                <!-- Order Information Panel -->
                <asp:Panel ID="pnlOrderDetails" runat="server" Visible="false">
                    <div class="row g-4 mb-4">
                        <!-- Order Information Card -->
                        <div class="col-lg-6">
                            <div class="card h-100 border-0 shadow-sm">
                                <div class="card-header bg-gradient-primary text-white border-0 py-3">
                                    <div class="d-flex align-items-center">
                                        <i class="fas fa-clipboard-list me-2"></i>
                                        <h5 class="mb-0 fw-semibold">Order Information</h5>
                                    </div>
                                </div>
                                <div class="card-body p-4">
                                    <div class="row g-3">
                                        <div class="col-sm-6">
                                            <div class="info-group">
                                                <label class="info-label">Order ID</label>
                                                <p class="info-value">#<asp:Label ID="lblOrderId" runat="server"></asp:Label></p>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-group">
                                                <label class="info-label">Order Date</label>
                                                <p class="info-value"><asp:Label ID="lblOrderDate" runat="server"></asp:Label></p>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-group">
                                                <label class="info-label">Status</label>
                                                <p class="info-value">
                                                    <asp:Label ID="lblStatus" runat="server" CssClass="badge fs-6 px-3 py-2"></asp:Label>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-group">
                                                <label class="info-label">Payment Method</label>
                                                <p class="info-value"><asp:Label ID="lblPaymentMethod" runat="server"></asp:Label></p>
                                            </div>
                                        </div>
                                        <div class="col-12">
                                            <div class="info-group">
                                                <label class="info-label">Total Amount</label>
                                                <h3 class="text-success fw-bold mb-0">$<asp:Label ID="lblTotalAmount" runat="server"></asp:Label></h3>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Admin Controls -->
                                    <asp:Panel ID="pnlAdminControls" runat="server" Visible="false" CssClass="mt-4">
                                        <div class="admin-controls bg-light p-3 rounded">
                                            <h6 class="text-primary mb-3">
                                                <i class="fas fa-user-shield me-2"></i>Admin Controls
                                            </h6>
                                            <div class="row g-3 align-items-end">
                                                <div class="col-md-8">
                                                    <label class="form-label fw-semibold">Update Status</label>
                                                    <asp:DropDownList ID="ddlUpdateStatus" runat="server" CssClass="form-select shadow-sm">
                                                        <asp:ListItem Text="Pending" Value="Pending" />
                                                        <asp:ListItem Text="Processing" Value="Processing" />
                                                        <asp:ListItem Text="Shipped" Value="Shipped" />
                                                        <asp:ListItem Text="Delivered" Value="Delivered" />
                                                        <asp:ListItem Text="Completed" Value="Completed" />
                                                        <asp:ListItem Text="Cancelled" Value="Cancelled" />
                                                    </asp:DropDownList>
                                                </div>
                                                <div class="col-md-4">
                                                    <asp:Button ID="btnUpdateStatus" runat="server" Text="Update Status" 
                                                        CssClass="btn btn-warning w-100 shadow-sm" OnClick="btnUpdateStatus_Click" />
                                                </div>
                                            </div>
                                        </div>
                                    </asp:Panel>
                                </div>
                            </div>
                        </div>

                        <!-- Customer Information Card -->
                        <div class="col-lg-6">
                            <div class="card h-100 border-0 shadow-sm">
                                <div class="card-header bg-gradient-info text-white border-0 py-3">
                                    <div class="d-flex align-items-center">
                                        <i class="fas fa-user me-2"></i>
                                        <h5 class="mb-0 fw-semibold">Customer Information</h5>
                                    </div>
                                </div>
                                <div class="card-body p-4">
                                    <div class="info-group mb-3">
                                        <label class="info-label">Customer Name</label>
                                        <p class="info-value"><asp:Label ID="lblCustomerName" runat="server"></asp:Label></p>
                                    </div>

                                    <div class="row g-3 mb-3">
                                        <div class="col-sm-6">
                                            <div class="info-group">
                                                <label class="info-label">Phone Number</label>
                                                <p class="info-value">
                                                    <i class="fas fa-phone-alt text-muted me-2"></i>
                                                    <asp:Label ID="lblPhone" runat="server"></asp:Label>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-group">
                                                <label class="info-label">Email Address</label>
                                                <p class="info-value">
                                                    <i class="fas fa-envelope text-muted me-2"></i>
                                                    <asp:Label ID="lblEmail" runat="server"></asp:Label>
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="info-group">
                                        <label class="info-label">Delivery Address</label>
                                        <div class="address-box bg-light p-3 rounded border-start border-4 border-info">
                                            <i class="fas fa-map-marker-alt text-muted me-2"></i>
                                            <asp:Label ID="lblAddress" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Order Items Card -->
                    <div class="card border-0 shadow-sm">
                        <div class="card-header bg-gradient-secondary text-white border-0 py-3">
                            <div class="d-flex align-items-center justify-content-between">
                                <div>
                                    <i class="fas fa-shopping-bag me-2"></i>
                                    <span class="fw-semibold">Order Items</span>
                                </div>
                                <small class="opacity-75">Product details and seller information</small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <asp:GridView ID="gvOrderItems" runat="server" AutoGenerateColumns="False" 
                                    CssClass="table table-hover mb-0 modern-table">
                                    <Columns>
                                        <asp:BoundField DataField="ProductId" HeaderText="ID" ItemStyle-CssClass="text-center fw-semibold" HeaderStyle-CssClass="bg-light text-center" />
                                        
                                        <asp:BoundField DataField="ProductName" HeaderText="Product Name" HeaderStyle-CssClass="bg-light" ItemStyle-CssClass="fw-semibold" />
                                        
                                        <asp:BoundField DataField="Quantity" HeaderText="Qty" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="bg-light text-center" />
                                        
                                        <asp:BoundField DataField="Price" HeaderText="Unit Price" DataFormatString="${0:0.00}" ItemStyle-CssClass="text-end fw-semibold" HeaderStyle-CssClass="bg-light text-end" />
                                        
                                        <asp:TemplateField HeaderText="Subtotal" HeaderStyle-CssClass="bg-light text-end">
                                            <ItemTemplate>
                                                <span class="text-success fw-bold">
                                                    $<%# (Convert.ToInt32(Eval("Quantity")) * Convert.ToDecimal(Eval("Price"))).ToString("0.00") %>
                                                </span>
                                            </ItemTemplate>
                                            <ItemStyle CssClass="text-end" />
                                        </asp:TemplateField>
                                        
                                        <asp:TemplateField HeaderText="Seller Information" HeaderStyle-CssClass="bg-light">
                                            <ItemTemplate>
                                                <div class="seller-info">
                                                    <div class="seller-name fw-semibold text-primary">
                                                        <i class="fas fa-store me-1"></i>
                                                        <asp:Label ID="lblSellerName" runat="server" Text='<%# Eval("SellerName") %>'></asp:Label>
                                                    </div>
                                                    <div class="seller-email text-muted small mt-1">
                                                        <i class="fas fa-envelope me-1"></i>
                                                        <asp:Label ID="lblSellerEmail" runat="server" Text='<%# Eval("SellerEmail") %>'></asp:Label>
                                                    </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="text-center py-5 text-muted">
                                            <i class="fas fa-box-open fa-3x mb-3"></i>
                                            <p class="mb-0">No items found in this order</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </main>

    <style>
        .bg-gradient-primary {
            background: linear-gradient(135deg, #007bff, #0056b3) !important;
        }
        
        .bg-gradient-info {
            background: linear-gradient(135deg, #17a2b8, #117a8b) !important;
        }
        
        .bg-gradient-secondary {
            background: linear-gradient(135deg, #6c757d, #495057) !important;
        }
        
        .info-group {
            margin-bottom: 0;
        }
        
        .info-label {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            color: #6c757d;
            letter-spacing: 0.5px;
            margin-bottom: 0.25rem;
            display: block;
        }
        
        .info-value {
            font-size: 0.95rem;
            color: #2c3e50;
            margin-bottom: 0;
            font-weight: 500;
        }
        
        .card {
            transition: all 0.2s ease-in-out;
        }
        
        .card:hover {
            transform: translateY(-2px);
        }
        
        .address-box {
            border-left-width: 4px !important;
        }
        
        .admin-controls {
            border: 1px solid #e9ecef;
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        }
        
        .modern-table {
            border-collapse: separate;
            border-spacing: 0;
        }
        
        .modern-table th {
            border-bottom: 2px solid #dee2e6;
            font-weight: 600;
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 1rem 0.75rem;
        }
        
        .modern-table td {
            padding: 1rem 0.75rem;
            border-bottom: 1px solid #f1f3f4;
            vertical-align: middle;
        }
        
        .modern-table tbody tr {
            transition: background-color 0.15s ease-in-out;
        }
        
        .modern-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .seller-info {
            min-width: 200px;
        }
        
        .seller-name {
            font-size: 0.9rem;
        }
        
        .seller-email {
            font-size: 0.8rem;
        }
        
        .badge {
            font-weight: 500;
            border-radius: 20px;
        }
        
        .btn {
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.2s ease-in-out;
        }
        
        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        
        .shadow-sm {
            box-shadow: 0 2px 4px rgba(0,0,0,0.1) !important;
        }
        
        @media (max-width: 768px) {
            .container-fluid {
                padding: 0.5rem;
            }
            
            .card-body {
                padding: 1.5rem !important;
            }
            
            .info-value {
                font-size: 0.9rem;
            }
            
            .modern-table th,
            .modern-table td {
                padding: 0.75rem 0.5rem;
                font-size: 0.85rem;
            }
        }
    </style>
</asp:Content>