<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" MasterPageFile="~/Site.Master" Inherits="WebApplication1.AdminDashboard" %>
<%@ Register Src="~/Controls/PaginationControl.ascx" TagPrefix="uc" TagName="Pagination" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        /* --- MODERN DASHBOARD THEME --- */
        .dashboard-page {
            background-color: #f8f9fa;
            min-height: 90vh;
            padding-top: 2rem;
            padding-bottom: 4rem;
        }

        .dashboard-card {
            border: none;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }

        .dashboard-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #f0f0f0;
            background: #fff;
        }

        .dashboard-header h5 {
            margin: 0;
            font-weight: 700;
            color: #2c3e50;
        }

        /* Nav Tabs Styling (Pills) */
        .nav-pills .nav-link {
            border-radius: 50px;
            padding: 0.6rem 1.5rem;
            font-weight: 600;
            color: #6c757d;
            margin-right: 0.5rem;
            transition: all 0.2s;
            border: 1px solid transparent;
            cursor: pointer;
        }

        .nav-pills .nav-link.active {
            background-color: #212529; /* Dark theme active */
            color: #fff;
            box-shadow: 0 4px 6px rgba(33, 37, 41, 0.3);
        }

        .nav-pills .nav-link:hover:not(.active) {
            background-color: #fff;
            border-color: #dee2e6;
            color: #000;
        }

        /* Input Groups & Forms */
        .input-group-text {
            background-color: #f8f9fa;
            border-right: none;
            color: #6c757d;
        }
        .form-control, .form-select {
            border-left: none;
            box-shadow: none !important;
        }
        .input-group:focus-within .input-group-text,
        .input-group:focus-within .form-control,
        .input-group:focus-within .form-select {
            border-color: #86b7fe;
        }

        /* GridView Images */
        .product-thumb {
            width: 50px; 
            height: 50px; 
            object-fit: cover; 
            border-radius: 6px;
            border: 1px solid #dee2e6;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .product-thumb:hover { transform: scale(1.1); }

        /* --- MOBILE TABLE CARDS (Responsive GridView) --- */
        @media screen and (max-width: 992px) {
            .mobile-card-table thead { display: none !important; }
            
            .mobile-card-table, .mobile-card-table tbody, .mobile-card-table tr, .mobile-card-table td {
                display: block;
                width: 100%;
            }

            .mobile-card-table tr {
                margin-bottom: 1rem;
                border: 1px solid #eee;
                border-radius: 10px;
                background: #fff;
                box-shadow: 0 2px 5px rgba(0,0,0,0.05);
                padding: 15px;
            }

            .mobile-card-table td {
                display: flex;
                justify-content: space-between;
                align-items: center;
                text-align: right;
                padding: 10px 0;
                border-bottom: 1px dashed #f0f0f0;
                position: relative;
                min-height: 40px;
            }

            .mobile-card-table td:last-child { border-bottom: none; justify-content: flex-end; gap: 5px; padding-top: 15px; flex-wrap: wrap; }

            /* Labels via CSS */
            .mobile-card-table td:before {
                content: attr(data-label); /* Fallback */
                font-weight: 700;
                color: #6c757d;
                font-size: 0.8rem;
                text-transform: uppercase;
                margin-right: auto; 
                max-width: 40%;
                text-align: left;
            }

            /* --- LABELS FOR PRODUCTS TABLE (Admin View) --- */
            #<%= gvProducts.ClientID %> td:nth-of-type(1):before { content: "ID"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(2):before { content: "Product Name"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(3):before { content: "Description"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(4):before { content: "Price"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(5):before { content: "Seller"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(6):before { content: "Status"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(7):before { content: "Image"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(8):before { content: ""; display: none; }

            /* --- LABELS FOR USERS TABLE --- */
            #<%= gvUsers.ClientID %> td:nth-of-type(1):before { content: "Email"; }
            #<%= gvUsers.ClientID %> td:nth-of-type(2):before { content: "Display Name"; }
            #<%= gvUsers.ClientID %> td:nth-of-type(3):before { content: "Role"; }
            #<%= gvUsers.ClientID %> td:nth-of-type(4):before { content: "Email Confirmed"; }
            #<%= gvUsers.ClientID %> td:nth-of-type(5):before { content: "Lockout"; }
            #<%= gvUsers.ClientID %> td:nth-of-type(6):before { content: ""; display: none; }

            /* --- LABELS FOR ORDERS TABLE --- */
            #<%= gvOrders.ClientID %> td:nth-of-type(1):before { content: "Order #"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(2):before { content: "Customer"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(3):before { content: "Order Date"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(4):before { content: "Total"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(5):before { content: "Status"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(6):before { content: "Payment"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(7):before { content: ""; display: none; }

            /* Fix description text overflow on mobile */
            #<%= gvProducts.ClientID %> td:nth-of-type(3) span {
                display: block;
                max-width: 200px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
        }
    </style>

    <div class="dashboard-page">
        <div class="container">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold text-dark mb-0">Admin Dashboard</h2>
                    <p class="text-muted mb-0">Manage platform users, products, and orders.</p>
                </div>
            </div>

            <asp:HiddenField ID="hfActiveTab" runat="server" Value="products" />

            <!-- Modern Pills Navigation -->
            <ul class="nav nav-pills mb-4" id="adminTabs" role="tablist">
                <li class="nav-item">
                    <button class="nav-link active" id="products-tab" data-bs-toggle="pill" data-bs-target="#products" type="button" onclick="setActiveTab('products')">
                        <i class="fas fa-box me-1"></i> Products
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" id="users-tab" data-bs-toggle="pill" data-bs-target="#users" type="button" onclick="setActiveTab('users')">
                        <i class="fas fa-users me-1"></i> Users
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" id="orders-tab" data-bs-toggle="pill" data-bs-target="#orders" type="button" onclick="setActiveTab('orders')">
                        <i class="fas fa-shopping-cart me-1"></i> Orders
                    </button>
                </li>
            </ul>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-info d-block shadow-sm border-0 mb-4" Visible="false"></asp:Label>

            <div class="tab-content">
                
                <!-- TAB 1: PRODUCTS -->
                <div class="tab-pane fade show active" id="products">
                    <div class="dashboard-card">
                        <div class="dashboard-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <h5 class="mb-0">Product Management</h5>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:DropDownList ID="ddlSellers" runat="server" CssClass="form-select form-select-sm w-auto border-0 bg-light" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlSellers_SelectedIndexChanged">
                                    <asp:ListItem Text="Filter: All Sellers" Value="" />
                                </asp:DropDownList>
                                <input type="text" id="txtSearchProduct" placeholder="Search Product..." class="form-control form-control-sm w-auto border-0 bg-light" onkeyup="filterProductTable()" />
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <asp:GridView ID="gvProducts" runat="server" AutoGenerateColumns="False" DataKeyNames="Id"
                                CssClass="table table-hover align-middle mb-0 mobile-card-table" GridLines="None" OnRowCommand="gvProducts_RowCommand">
                                <HeaderStyle CssClass="bg-light text-muted small text-uppercase fw-bold border-bottom" />
                                <Columns>
                                    <asp:BoundField DataField="Id" HeaderText="ID" />
                                    
                                    <asp:TemplateField HeaderText="Product Name">
                                        <ItemTemplate>
                                            <span class="fw-bold text-dark" title='<%# Eval("Name") %>'>
                                                <%# Convert.ToString(Eval("Name")).Length > 50 ? Convert.ToString(Eval("Name")).Substring(0, 50) + "..." : Eval("Name") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Description">
                                        <ItemTemplate>
                                            <span class="text-muted small" title='<%# Eval("Description") %>'>
                                                <%# Convert.ToString(Eval("Description")).Length > 60 ? Convert.ToString(Eval("Description")).Substring(0, 60) + "..." : Eval("Description") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="${0:0.00}" />
                                    <asp:BoundField DataField="SellerDisplayName" HeaderText="Seller" />
                                    <asp:BoundField DataField="Status" HeaderText="Status" />
                                    
                                    <asp:TemplateField HeaderText="Image">
                                        <ItemTemplate>
                                            <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>' class="product-thumb"
                                                 onclick='showImageModal("<%# ResolveUrl(Eval("ImageUrl").ToString()) %>")' alt="Product" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:Button ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("Id") %>'
                                                Text="Approve" CssClass="btn btn-success btn-sm py-0" 
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>' />
                                            <asp:Button ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("Id") %>'
                                                Text="Reject" CssClass="btn btn-outline-danger btn-sm py-0"
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>

                            <div class="p-3 border-top">
                                <uc:Pagination ID="productsPagination" runat="server" 
                                    OnPageChanged="productsPagination_PageChanged" 
                                    OnPageSizeChanged="productsPagination_PageSizeChanged" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: USERS -->
                <div class="tab-pane fade" id="users">
                    <div class="dashboard-card">
                        <div class="dashboard-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <h5 class="mb-0">User Management</h5>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="form-select form-select-sm w-auto border-0 bg-light" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlRoleFilter_SelectedIndexChanged">
                                    <asp:ListItem Text="Filter: All Users" Value="" />
                                    <asp:ListItem Text="Customers" Value="Customer" />
                                    <asp:ListItem Text="Sellers" Value="Seller" />
                                    <asp:ListItem Text="Admins" Value="Admin" />
                                </asp:DropDownList>
                                <input type="text" id="txtSearchUser" placeholder="Search User..." class="form-control form-control-sm w-auto border-0 bg-light" onkeyup="filterUserTable()" />
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" DataKeyNames="Id"
                                CssClass="table table-hover align-middle mb-0 mobile-card-table" GridLines="None"
                                OnRowCommand="gvUsers_RowCommand" OnRowEditing="gvUsers_RowEditing"
                                OnRowCancelingEdit="gvUsers_RowCancelingEdit" OnRowUpdating="gvUsers_RowUpdating">
                                <HeaderStyle CssClass="bg-light text-muted small text-uppercase fw-bold border-bottom" />
                                <Columns>
                                    <asp:BoundField DataField="Email" HeaderText="Email" ReadOnly="true" />
                                    <asp:BoundField DataField="DisplayName" HeaderText="Display Name" ReadOnly="true" />
                                    <asp:TemplateField HeaderText="Role">
                                        <ItemTemplate>
                                            <asp:Label ID="lblRole" runat="server" Text='<%# Eval("RoleName") %>' CssClass='<%# "badge rounded-pill bg-secondary " + GetRoleBadgeClass(Eval("RoleName").ToString()) %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Confirmed">
                                        <ItemTemplate>
                                            <%# Convert.ToBoolean(Eval("EmailConfirmed")) ? "<i class='fas fa-check-circle text-success'></i>" : "<i class='fas fa-times-circle text-warning'></i>" %>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:CheckBox ID="chkEmailConfirmed" runat="server" Checked='<%# Convert.ToBoolean(Eval("EmailConfirmed")) %>' />
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Lockout">
                                        <ItemTemplate>
                                            <%# Convert.ToBoolean(Eval("LockoutEnabled")) ? "<span class='badge bg-danger'>Locked</span>" : "<span class='badge bg-success'>Active</span>" %>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:CheckBox ID="chkLockoutEnabled" runat="server" Checked='<%# Convert.ToBoolean(Eval("LockoutEnabled")) %>' />
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:Button ID="btnEdit" runat="server" CommandName="Edit" Text="Edit" CssClass="btn btn-sm btn-outline-primary py-0" />
                                            <asp:Button ID="btnViewDetails" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>'
                                                Text="Details" CssClass="btn btn-sm btn-light border py-0" />
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:Button ID="btnUpdate" runat="server" CommandName="Update" Text="Save" CssClass="btn btn-sm btn-success py-0" />
                                            <asp:Button ID="btnCancel" runat="server" CommandName="Cancel" Text="Cancel" CssClass="btn btn-sm btn-light border py-0" />
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                            
                            <div class="p-3 border-top">
                                <uc:Pagination ID="usersPagination" runat="server" 
                                    OnPageChanged="usersPagination_PageChanged" 
                                    OnPageSizeChanged="usersPagination_PageSizeChanged" />
                            </div>
                        </div>
                    </div>

                    <!-- User Details Panel -->
                    <asp:Panel ID="pnlUserDetails" runat="server" Visible="false" CssClass="dashboard-card border border-info mt-3">
                        <div class="dashboard-header bg-info text-white d-flex justify-content-between align-items-center">
                            <h5 class="text-white mb-0">User Details</h5>
                            <asp:Button ID="btnCloseUserDetails" runat="server" Text="Close" CssClass="btn btn-sm btn-light text-dark" OnClick="btnCloseUserDetails_Click" />
                        </div>
                        <div class="card-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <h6 class="fw-bold text-uppercase small text-muted border-bottom pb-2">Account Info</h6>
                                    <p class="mb-1"><strong>User ID:</strong> <asp:Label ID="lblUserId" runat="server"></asp:Label></p>
                                    <p class="mb-1"><strong>Email:</strong> <asp:Label ID="lblUserEmail" runat="server"></asp:Label></p>
                                    <p class="mb-1"><strong>Name:</strong> <asp:Label ID="lblUserName" runat="server"></asp:Label></p>
                                    <p class="mb-1"><strong>Role:</strong> <asp:Label ID="lblUserRole" runat="server" CssClass="badge bg-primary"></asp:Label></p>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="fw-bold text-uppercase small text-muted border-bottom pb-2">Status</h6>
                                    <p class="mb-1"><strong>Confirmed:</strong> <asp:Label ID="lblEmailConfirmed" runat="server"></asp:Label></p>
                                    <p class="mb-1"><strong>Lockout:</strong> <asp:Label ID="lblLockoutEnabled" runat="server"></asp:Label></p>
                                    <p class="mb-1"><strong>Phone:</strong> <asp:Label ID="lblPhoneNumber" runat="server"></asp:Label></p>
                                </div>
                            </div>

                            <asp:Panel ID="pnlSellerStats" runat="server" Visible="false" CssClass="mt-4 pt-3 border-top">
                                <h6 class="fw-bold text-uppercase small text-muted mb-3">Seller Performance</h6>
                                <div class="row g-2">
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded text-center">
                                            <h4 class="fw-bold mb-0"><asp:Label ID="lblTotalProducts" runat="server" Text="0"></asp:Label></h4>
                                            <small class="text-muted">Total Products</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded text-center">
                                            <h4 class="fw-bold mb-0"><asp:Label ID="lblApprovedProducts" runat="server" Text="0"></asp:Label></h4>
                                            <small class="text-muted">Approved</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded text-center">
                                            <h4 class="fw-bold mb-0"><asp:Label ID="lblPendingProducts" runat="server" Text="0"></asp:Label></h4>
                                            <small class="text-muted">Pending</small>
                                        </div>
                                    </div>
                                </div>
                            </asp:Panel>

                            <asp:Panel ID="pnlCustomerStats" runat="server" Visible="false" CssClass="mt-4 pt-3 border-top">
                                <h6 class="fw-bold text-uppercase small text-muted mb-3">Customer Stats</h6>
                                <div class="row g-2">
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded text-center">
                                            <h4 class="fw-bold mb-0"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></h4>
                                            <small class="text-muted">Total Orders</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded text-center">
                                            <h4 class="fw-bold mb-0 text-success">$<asp:Label ID="lblTotalSpent" runat="server" Text="0.00"></asp:Label></h4>
                                            <small class="text-muted">Total Spent</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="p-3 bg-light rounded text-center">
                                            <h5 class="fw-bold mb-0"><asp:Label ID="lblLastOrderDate" runat="server" Text="N/A"></asp:Label></h5>
                                            <small class="text-muted">Last Order</small>
                                        </div>
                                    </div>
                                </div>
                            </asp:Panel>
                        </div>
                    </asp:Panel>
                </div>

                <!-- TAB 3: ORDERS -->
                <div class="tab-pane fade" id="orders">
                    <div class="dashboard-card">
                        <div class="dashboard-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <h5 class="mb-0">Order Management</h5>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:DropDownList ID="ddlOrderStatus" runat="server" CssClass="form-select form-select-sm w-auto border-0 bg-light" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlOrderStatus_SelectedIndexChanged">
                                    <asp:ListItem Text="Filter: All" Value="" />
                                    <asp:ListItem Text="Pending" Value="Pending" />
                                    <asp:ListItem Text="Processing" Value="Processing" />
                                    <asp:ListItem Text="Shipped" Value="Shipped" />
                                    <asp:ListItem Text="Delivered" Value="Delivered" />
                                    <asp:ListItem Text="Completed" Value="Completed" />
                                    <asp:ListItem Text="Cancelled" Value="Cancelled" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <asp:GridView ID="gvOrders" runat="server" AutoGenerateColumns="False" DataKeyNames="OrderId"
                                CssClass="table table-hover align-middle mb-0 mobile-card-table" GridLines="None" OnRowCommand="gvOrders_RowCommand" OnRowDataBound="gvOrders_RowDataBound">
                                <HeaderStyle CssClass="bg-light text-muted small text-uppercase fw-bold border-bottom" />
                                <Columns>
                                    <asp:BoundField DataField="OrderId" HeaderText="Order #" />
                                    <asp:BoundField DataField="CustomerName" HeaderText="Customer" />
                                    <asp:BoundField DataField="OrderDate" HeaderText="Order Date" DataFormatString="{0:MMM dd, yyyy}" />
                                    <asp:BoundField DataField="TotalAmount" HeaderText="Total" DataFormatString="${0:0.00}" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <div class="d-flex align-items-center gap-2 justify-content-end justify-content-md-start">
                                                <asp:Label ID="lblOrderStatus" runat="server" Text='<%# Eval("Status") %>' 
                                                    CssClass='<%# "badge rounded-pill " + GetOrderStatusBadgeClass(Eval("Status").ToString()) %>'>
                                                </asp:Label>
                                                <asp:DropDownList ID="ddlOrderStatusUpdate" runat="server" 
                                                    CssClass="form-select form-select-sm py-0" 
                                                    AutoPostBack="true" 
                                                    OnSelectedIndexChanged="ddlOrderStatusUpdate_SelectedIndexChanged"
                                                    style="width: auto; font-size: 0.8rem;">
                                                </asp:DropDownList>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="PaymentMethod" HeaderText="Payment" />
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:Button ID="btnViewOrder" runat="server" CommandName="ViewOrder" CommandArgument='<%# Eval("OrderId") %>'
                                                Text="Details" CssClass="btn btn-info btn-sm text-white py-0" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                            
                            <div class="p-3 border-top">
                                <uc:Pagination ID="ordersPagination" runat="server" 
                                    OnPageChanged="ordersPagination_PageChanged" 
                                    OnPageSizeChanged="ordersPagination_PageSizeChanged" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Image Modal -->
    <div class="modal fade" id="imageModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center p-4">
                    <img id="modalImg" src="" class="img-fluid rounded shadow-sm" />
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function setActiveTab(tabName) {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf) hf.value = tabName;
        }

        document.addEventListener('DOMContentLoaded', function() {
            var activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value || 'products';

            // Reset Tabs
            var tabs = document.querySelectorAll('.nav-link');
            tabs.forEach(function(tab) { tab.classList.remove('active'); });
            var tabContents = document.querySelectorAll('.tab-pane');
            tabContents.forEach(function(content) { content.classList.remove('show', 'active'); });
            
            // Activate correct tab (Bootstrap 5 API)
            var triggerEl = document.querySelector('#' + activeTab + '-tab');
            if (triggerEl) {
                var tab = new bootstrap.Tab(triggerEl);
                tab.show();
            }
        });

        function showImageModal(url) {
            document.getElementById('modalImg').src = url;
            var myModal = new bootstrap.Modal(document.getElementById('imageModal'));
            myModal.show();
        }

        function filterProductTable() {
            var input = document.getElementById("txtSearchProduct");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("<%= gvProducts.ClientID %>");
            if(!table) return;
            var tr = table.getElementsByTagName("tr");
            for (var i = 1; i < tr.length; i++) {
                var rowContent = tr[i].textContent || tr[i].innerText;
                if (rowContent) {
                    tr[i].style.display = rowContent.toUpperCase().indexOf(filter) > -1 ? "" : "none";
                }
            }
        }

        function filterUserTable() {
            var input = document.getElementById("txtSearchUser");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("<%= gvUsers.ClientID %>");
            if (!table) return;
            var tr = table.getElementsByTagName("tr");
            for (var i = 1; i < tr.length; i++) {
                var rowContent = tr[i].textContent || tr[i].innerText;
                if (rowContent) {
                    tr[i].style.display = rowContent.toUpperCase().indexOf(filter) > -1 ? "" : "none";
                }
            }
        }
    </script>
</asp:Content>