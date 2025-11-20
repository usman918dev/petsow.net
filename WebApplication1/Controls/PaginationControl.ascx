<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PaginationControl.ascx.cs" Inherits="WebApplication1.Controls.PaginationControl" %>

<!-- Custom Styles for Dark Theme Pagination -->
<style>
    .pagination-custom .page-item.active .page-link {
        background-color: #212529 !important; /* Dark background */
        border-color: #212529 !important;
        color: white !important;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    .pagination-custom .page-link {
        color: #495057;
        border: none;
        margin: 0 2px;
        border-radius: 4px !important;
        font-weight: 500;
    }
    .pagination-custom .page-link:hover {
        background-color: #e9ecef;
        color: #000;
    }
    .page-size-select {
        background-position: right 0.5rem center;
        padding-right: 2rem;
    }
</style>

<!-- DESKTOP VIEW -->
<div class="d-none d-md-flex justify-content-between align-items-center mt-4 pt-3 border-top" id="paginationWrapper" runat="server">
    
    <!-- Page Info -->
    <div class="pagination-info text-muted small">
        Showing <span class="fw-bold text-dark"><asp:Label ID="lblStartRecord" runat="server"></asp:Label></span> 
        to <span class="fw-bold text-dark"><asp:Label ID="lblEndRecord" runat="server"></asp:Label></span> 
        of <span class="fw-bold text-dark"><asp:Label ID="lblTotalRecords" runat="server"></asp:Label></span> entries
    </div>

    <!-- Pagination Controls -->
    <nav aria-label="Page navigation">
        <ul class="pagination pagination-custom pagination-sm mb-0 align-items-center">
            <!-- Previous Button -->
            <li class="page-item" id="liPrevious" runat="server">
                <asp:LinkButton ID="btnPrevious" runat="server" 
                    CssClass="page-link" 
                    OnClick="btnPrevious_Click"
                    CommandArgument="previous">
                    <i class="fas fa-chevron-left"></i>
                </asp:LinkButton>
            </li>

            <!-- Page Numbers -->
            <asp:Repeater ID="rptPageNumbers" runat="server" OnItemCommand="rptPageNumbers_ItemCommand">
                <ItemTemplate>
                    <li class="page-item <%# (int)Eval("PageNumber") == CurrentPage ? "active" : "" %>">
                        <asp:LinkButton ID="btnPageNumber" runat="server"
                            CssClass="page-link"
                            CommandName="PageNumber"
                            CommandArgument='<%# Eval("PageNumber") %>'
                            Text='<%# Eval("PageNumber") %>'
                            Enabled='<%# (int)Eval("PageNumber") != CurrentPage %>'>
                        </asp:LinkButton>
                    </li>
                </ItemTemplate>
            </asp:Repeater>

            <!-- Next Button -->
            <li class="page-item" id="liNext" runat="server">
                <asp:LinkButton ID="btnNext" runat="server" 
                    CssClass="page-link" 
                    OnClick="btnNext_Click"
                    CommandArgument="next">
                    <i class="fas fa-chevron-right"></i>
                </asp:LinkButton>
            </li>
        </ul>
    </nav>

    <!-- Page Size Selector -->
    <div class="page-size-selector d-flex align-items-center">
        <small class="text-muted me-2 text-uppercase fw-bold" style="font-size: 0.7rem;">Rows:</small>
        <asp:DropDownList ID="ddlPageSize" runat="server" 
            CssClass="form-select form-select-sm border-0 bg-light fw-bold text-secondary page-size-select" 
            AutoPostBack="true" 
            OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged"
            style="width: auto; cursor: pointer;">
            <asp:ListItem Value="5">5</asp:ListItem>
            <asp:ListItem Value="10" Selected="True">10</asp:ListItem>
            <asp:ListItem Value="25">25</asp:ListItem>
            <asp:ListItem Value="50">50</asp:ListItem>
        </asp:DropDownList>
    </div>
</div>

<!-- MOBILE VIEW -->
<div class="d-block d-md-none mt-3 pt-3 border-top" id="mobilePagination" runat="server">
    <div class="d-flex justify-content-between align-items-center">
        <asp:Button ID="btnMobilePrevious" runat="server" 
            Text="Previous" 
            CssClass="btn btn-outline-secondary btn-sm rounded-pill px-3 shadow-sm"
            OnClick="btnPrevious_Click" />
        
        <span class="badge bg-light text-dark border shadow-sm">
            Page <asp:Label ID="lblMobileCurrentPage" runat="server" CssClass="fw-bold"></asp:Label> 
            of <asp:Label ID="lblMobileTotalPages" runat="server"></asp:Label>
        </span>
        
        <asp:Button ID="btnMobileNext" runat="server" 
            Text="Next" 
            CssClass="btn btn-outline-secondary btn-sm rounded-pill px-3 shadow-sm"
            OnClick="btnNext_Click" />
    </div>
    
    <div class="text-center mt-2">
        <small class="text-muted" style="font-size: 0.75rem;">
            Total Records: <asp:Label ID="lblMobileTotalRecords" runat="server" CssClass="fw-bold text-dark"></asp:Label>
        </small>
    </div>
</div>