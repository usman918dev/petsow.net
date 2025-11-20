<% @Page Title = "Shop - Pet Store" Language = "C#" MasterPageFile = "~/Site.Master" AutoEventWireup = "true" CodeBehind = "Shop.aspx.cs" Inherits = "WebApplication1.Shop" %>
<% @Register Src = "~/Controls/PaginationControl.ascx" TagPrefix = "uc" TagName = "Pagination" %>

  <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Custom CSS for Shop Page -->
    <style>
      .shop-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
   margin-top:-30px;
   padding-top: 100px;
   padding-bottom: 140px; /* Extra space for the wave */
   position: relative;
   overflow: hidden;
   width: 100vw;             
   margin-left: -50vw;       
   left: 50%;
        }

      .search-section {
        background: #f8f9fa;
      padding: 30px 0;
        }

      .product-card {
        transition: transform 0.3s ease, box-shadow 0.3s ease;
      border: none;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

      .product-card:hover {
        transform: translateY(-8px);
      box-shadow: 0 12px 30px rgba(0,0,0,0.15);
        }

      .product-price {
        font-size: 1.25rem;
      font-weight: bold;
      color: #28a745;
        }

      .btn-custom {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      padding: 8px 20px;
      border-radius: 25px;
      color: white;
      transition: transform 0.3s ease;
        }

      .btn-custom:hover {
        transform: translateY(-2px);
      color: white;
        }

      .search-box {
        border-radius: 25px;
      border: 2px solid #e9ecef;
      padding: 12px 20px;
        }

      .search-box:focus {
        border-color: #667eea;
      box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }

      .btn-search {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      border-radius: 25px;
      padding: 12px 25px;
      color: white;
        }

      .results-info {
        color: #6c757d;
      margin-bottom: 20px;
        }

      .no-products {
        text-align: center;
      padding: 60px 0;
      color: #6c757d;
        }

      .no-products i {
        font-size: 4rem;
      margin-bottom: 20px;
      opacity: 0.5;
        }

      .price-range-section {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 15px;
        margin-top: 15px;
      }

      .form-label {
        color: #495057;
        font-weight: 600;
        margin-bottom: 5px;
      }

      .btn-outline-primary {
        border-color: #667eea;
        color: #667eea;
      }

      .btn-outline-primary:hover {
        background-color: #667eea;
        border-color: #667eea;
        color: white;
      }

      .btn-outline-secondary {
        border-color: #6c757d;
        color: #6c757d;
      }

      .btn-outline-secondary:hover {
        background-color: #6c757d;
        border-color: #6c757d;
        color: white;
      }
    </style>

    <!-- Shop Header -->
    <section class="shop-header">
      <div class="container">
        <div class="row">
          <div class="col-lg-8 mx-auto text-center">
            <h1 class="display-4 fw-bold mb-3">Pet Store Shop</h1>
            <p class="lead mb-0">Find the perfect products for your beloved pets</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Search Section -->
    <section class="search-section">
      <div class="container">
        <div class="row justify-content-center">
          <div class="col-lg-10">
            <div class="card border-0 shadow-sm">
              <div class="card-body p-4">
                <div class="row g-3 align-items-end">
                  <div class="col-md-6">
                    <label for="txtSearch" class="form-label fw-bold">Search Products</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control search-box"
                      placeholder="Search by product name..." />
                  </div>
                  <div class="col-md-3">
                    <label for="ddlPriceRange" class="form-label fw-bold">Price Range</label>
                    <asp:DropDownList ID="ddlPriceRange" runat="server" CssClass="form-select">
                      <asp:ListItem Text="All Prices" Value="" />
                      <asp:ListItem Text="Under $25" Value="0-25" />
                      <asp:ListItem Text="$25 - $50" Value="25-50" />
                      <asp:ListItem Text="$50 - $100" Value="50-100" />
                      <asp:ListItem Text="$100 - $200" Value="100-200" />
                      <asp:ListItem Text="Over $200" Value="200-999999" />
                    </asp:DropDownList>
                  </div>
                  <div class="col-md-3">
                    <asp:Button ID="btnSearch" runat="server" Text="Search & Filter" CssClass="btn btn-search w-100"
                      OnClick="btnSearch_Click" />
                  </div>
                </div>
                <div class="row mt-3">
                  <div class="col-md-6">
                    <div class="row g-2">
                      <div class="col-6">
                        <label for="txtMinPrice" class="form-label fw-bold">Min Price ($)</label>
                        <asp:TextBox ID="txtMinPrice" runat="server" CssClass="form-control" 
                          placeholder="0.00" TextMode="Number" step="0.01" min="0" />
                      </div>
                      <div class="col-6">
                        <label for="txtMaxPrice" class="form-label fw-bold">Max Price ($)</label>
                        <asp:TextBox ID="txtMaxPrice" runat="server" CssClass="form-control" 
                          placeholder="999.99" TextMode="Number" step="0.01" min="0" />
                      </div>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="d-flex gap-2 align-items-end h-100">
                      <asp:Button ID="btnApplyCustomRange" runat="server" Text="Apply Custom Range" 
                        CssClass="btn btn-outline-primary" OnClick="btnApplyCustomRange_Click" />
                      <asp:Button ID="btnClearSearch" runat="server" Text="Clear All Filters" 
                        CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Products Section -->
    <section class="py-5">
      <div class="container">
        <!-- Results Information -->
        <div class="row mb-4">
          <div class="col-12">
            <asp:Label ID="lblResultsInfo" runat="server" CssClass="results-info"></asp:Label>
          </div>
        </div>

        <!-- Products Grid -->
        <div class="row g-4" id="productsGrid">
          <asp:Repeater ID="rptProducts" runat="server" OnItemDataBound="rptProducts_ItemDataBound">
            <ItemTemplate>
              <div class="col-lg-4 col-md-6">
                <div class="card product-card h-100">
                  <div class="position-relative">
                    <asp:HyperLink ID="lnkProduct" runat="server" NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'>
                      <asp:Image ID="imgProduct" runat="server" CssClass="card-img-top"
                        style="height: 250px; object-fit: cover;" />
                    </asp:HyperLink>
                    <!-- Stock Status Badge -->
                    <div class="position-absolute top-0 end-0 m-3">
                      <span class='<%# Convert.ToInt32(Eval("Stock")) > 0 ? "badge bg-success" : "badge bg-danger" %>'>
                        <%# Convert.ToInt32(Eval("Stock")) > 0 ? "In Stock" : "Out of Stock" %>
                      </span>
                    </div>
                  </div>
                  <div class="card-body d-flex flex-column">
                    <h5 class="card-title mb-2">
                      <asp:HyperLink ID="lnkProductTitle" runat="server"
                        NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'
                        CssClass="text-decoration-none text-dark">
                        <%# Eval("Name") %>
                      </asp:HyperLink>
                    </h5>
                    <p class="card-text text-muted flex-grow-1">
                      <asp:Label ID="lblDescription" runat="server"></asp:Label>
                    </p>
                    <div class="mt-auto">
                      <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="product-price">$<%# Eval("Price", "{0:0.00}") %></span>
                        <small class="text-muted">Stock: <%# Eval("Stock") %></small>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </ItemTemplate>
          </asp:Repeater>
        </div>

        <!-- No Products Message -->
        <asp:Panel ID="pnlNoProducts" runat="server" CssClass="no-products" Visible="false">
          <i class="fas fa-search"></i>
          <h4>No Products Found</h4>
          <p class="mb-0">
            <asp:Label ID="lblNoProductsMessage" runat="server" Text="No products match your search criteria."></asp:Label>
          </p>
        </asp:Panel>

        <!-- Pagination -->
        <div class="row mt-5">
          <div class="col-12 d-flex justify-content-center">
            <uc:Pagination ID="productsPagination" runat="server"
              OnPageChanged="productsPagination_PageChanged" />
          </div>
        </div>
      </div>
    </section>
  </asp:Content>