using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using Microsoft.AspNet.Identity;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication1.Helpers;
using WebApplication1.Controls;
using System.Collections.Generic; // Added for List<SqlParameter>

namespace WebApplication1
{
    public partial class SellerDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        // Manual control declarations (matches your designer file)
        protected Controls.PaginationControl productsPagination;
        protected Controls.PaginationControl ordersPagination;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify user is Seller
            if (!User.Identity.IsAuthenticated || !User.IsInRole("Seller"))
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Set default active tab
                hfActiveTab.Value = "add-product";

                // Ensure edit panel is hidden
                pnlEditProduct.Visible = false;

                // Check if pagination controls are available
                if (productsPagination != null && ordersPagination != null)
                {
                    BindProductsWithPagination(1, 10); // Start with page 1, 10 records per page
                    BindOrdersWithPagination(1, 10);   // Start with page 1, 10 records per page
                }
                else
                {
                    // Fallback to non-paginated methods
                    System.Diagnostics.Trace.WriteLine("Pagination controls not available, using fallback methods.");
                    BindProductsFallback();
                    BindOrdersFallback();
                }

                LoadStatistics();

                // Clear any message from session if it exists
                if (Session["ProductMessage"] != null)
                {
                    ShowMessage(Session["ProductMessage"].ToString(), "alert-success");
                    Session.Remove("ProductMessage");
                }
            }
        }

        // --- FIXED: Updated Refresh Orders Logic ---
        protected void btnRefreshOrders_Click(object sender, EventArgs e)
        {
            // Keep the Orders tab active after postback
            hfActiveTab.Value = "orders";

            // Reload data based on available controls
            if (ordersPagination != null)
            {
                // Reload current page
                BindOrdersWithPagination(ordersPagination.CurrentPage, ordersPagination.PageSize);
            }
            else
            {
                BindOrdersFallback();
            }

            // Update statistics to ensure they are current
            LoadStatistics();
            ShowMessage("Orders refreshed successfully.", "alert-success");
        }

        #region Product Management with Pagination

        private void BindProductsWithPagination(int currentPage, int pageSize)
        {
            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                // Validate pagination parameters
                PaginationHelper.ValidatePaginationParams(ref currentPage, ref pageSize);

                // Build queries
                string baseQuery = @"
                    SELECT Id, Name, Description, Price, ImageUrl, Status, 
                           ISNULL(Stock, 0) as Stock, 
                           ISNULL(StockStatus, 'In Stock') as StockStatus 
                    FROM PetSupplies 
                    WHERE SellerId = @SellerId";

                string countQuery = @"
                    SELECT COUNT(*) 
                    FROM PetSupplies 
                    WHERE SellerId = @SellerId";

                // Add status filter if selected
                string statusFilter = ddlStatusFilter.SelectedValue;
                var parametersList = new List<SqlParameter>
                {
                    new SqlParameter("@SellerId", sellerId)
                };

                if (!string.IsNullOrEmpty(statusFilter))
                {
                    baseQuery += " AND Status = @Status";
                    countQuery += " AND Status = @Status";
                    parametersList.Add(new SqlParameter("@Status", statusFilter));
                }

                string orderByClause = "ORDER BY Id DESC";

                // Get paginated data
                var result = PaginationHelper.GetPaginatedData(
                    connStr, baseQuery, countQuery, orderByClause,
                    parametersList.ToArray(), currentPage, pageSize);

                // Bind data
                gvProducts.DataSource = result.Data;
                gvProducts.DataBind();

                // Update pagination control with null check
                if (productsPagination != null)
                {
                    productsPagination.SetPaginationData(result.TotalRecords, currentPage, pageSize);
                }
                else
                {
                    System.Diagnostics.Trace.WriteLine("Warning: productsPagination control is null, pagination not available.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error binding products: {ex}");
                ShowMessage("Error loading products.", "alert-danger");
            }
        }

        protected void productsPagination_PageChanged(object sender, PageChangedEventArgs e)
        {
            hfActiveTab.Value = "products"; // Stay on products tab
            BindProductsWithPagination(e.CurrentPage, e.PageSize);
        }

        protected void productsPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
        {
            hfActiveTab.Value = "products"; // Stay on products tab
            BindProductsWithPagination(e.CurrentPage, e.PageSize);
        }

        #endregion

        #region Order Management with Pagination

        private void BindOrdersWithPagination(int currentPage, int pageSize)
        {
            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                // Validate pagination parameters
                PaginationHelper.ValidatePaginationParams(ref currentPage, ref pageSize);

                // Build queries
                string baseQuery = @"
                    SELECT 
                        o.OrderId,
                        oi.ProductName,
                        oi.Quantity,
                        oi.Price,
                        (oi.Quantity * oi.Price) as TotalAmount,
                        o.CustomerName,
                        o.OrderDate,
                        o.Status as OrderStatus
                    FROM OrderItems oi
                    INNER JOIN Orders o ON oi.OrderId = o.OrderId
                    INNER JOIN PetSupplies p ON oi.ProductId = p.Id
                    WHERE p.SellerId = @SellerId";

                string countQuery = @"
                    SELECT COUNT(*)
                    FROM OrderItems oi
                    INNER JOIN Orders o ON oi.OrderId = o.OrderId
                    INNER JOIN PetSupplies p ON oi.ProductId = p.Id
                    WHERE p.SellerId = @SellerId";

                // Add status filter if selected
                string statusFilter = ddlOrderStatusFilter.SelectedValue;
                var parametersList = new List<SqlParameter>
                {
                    new SqlParameter("@SellerId", sellerId)
                };

                if (!string.IsNullOrEmpty(statusFilter))
                {
                    baseQuery += " AND o.Status = @Status";
                    countQuery += " AND o.Status = @Status";
                    parametersList.Add(new SqlParameter("@Status", statusFilter));
                }

                string orderByClause = "ORDER BY o.OrderDate DESC";

                // Get paginated data
                var result = PaginationHelper.GetPaginatedData(
                    connStr, baseQuery, countQuery, orderByClause,
                    parametersList.ToArray(), currentPage, pageSize);

                // Bind data
                gvOrders.DataSource = result.Data;
                gvOrders.DataBind();

                // Update pagination control with null check
                if (ordersPagination != null)
                {
                    ordersPagination.SetPaginationData(result.TotalRecords, currentPage, pageSize);
                }
                else
                {
                    System.Diagnostics.Trace.WriteLine("Warning: ordersPagination control is null, pagination not available.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error binding orders: {ex}");
                ShowMessage("Error loading orders.", "alert-danger");
            }
        }

        protected void ordersPagination_PageChanged(object sender, PageChangedEventArgs e)
        {
            hfActiveTab.Value = "orders"; // Stay on orders tab
            BindOrdersWithPagination(e.CurrentPage, e.PageSize);
        }

        protected void ordersPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
        {
            hfActiveTab.Value = "orders"; // Stay on orders tab
            BindOrdersWithPagination(e.CurrentPage, e.PageSize);
        }

        #endregion

        #region Event Handlers

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            hfActiveTab.Value = "products"; // Stay on products tab
            pnlEditProduct.Visible = false; // Hide edit form

            if (productsPagination != null)
            {
                BindProductsWithPagination(1, productsPagination.PageSize); // Reset to first page when filtering
            }
            else
            {
                BindProductsFallback();
            }
        }

        protected void ddlOrderStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            hfActiveTab.Value = "orders"; // Stay on orders tab

            if (ordersPagination != null)
            {
                BindOrdersWithPagination(1, ordersPagination.PageSize); // Reset to first page when filtering
            }
            else
            {
                BindOrdersFallback();
            }
        }

        protected void btnRefreshProducts_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "products"; // Stay on products tab
            pnlEditProduct.Visible = false; // Hide edit form

            if (productsPagination != null)
            {
                BindProductsWithPagination(productsPagination.CurrentPage, productsPagination.PageSize);
            }
            else
            {
                BindProductsFallback();
            }

            LoadStatistics();
            ShowMessage("Products refreshed successfully.", "alert-success");
        }

        #endregion

        #region Product Management

        protected void gvProducts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Set active tab to products when performing actions
            hfActiveTab.Value = "products";

            if (e.CommandName == "EditProduct")
            {
                int productId = Convert.ToInt32(e.CommandArgument);
                LoadProductForEdit(productId);
                pnlEditProduct.Visible = true;
                litEditFormTitle.Text = "Edit Product";
            }
        }

        protected void gvProducts_RowEditing(object sender, GridViewEditEventArgs e)
        {
            hfActiveTab.Value = "products";
            pnlEditProduct.Visible = false;
            gvProducts.EditIndex = e.NewEditIndex;
            BindProductsWithPagination(productsPagination?.CurrentPage ?? 1, productsPagination?.PageSize ?? 10);
        }

        protected void gvProducts_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            hfActiveTab.Value = "products";
            pnlEditProduct.Visible = false;
            gvProducts.EditIndex = -1;
            BindProductsWithPagination(productsPagination?.CurrentPage ?? 1, productsPagination?.PageSize ?? 10);
        }

        protected void gvProducts_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                hfActiveTab.Value = "products";
                GridViewRow row = gvProducts.Rows[e.RowIndex];
                int productId = Convert.ToInt32(gvProducts.DataKeys[e.RowIndex].Value);
                string sellerId = User.Identity.GetUserId();

                TextBox txtEditStock = (TextBox)row.FindControl("txtEditStock");
                DropDownList ddlEditStockStatus = (DropDownList)row.FindControl("ddlEditStockStatus");

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"UPDATE PetSupplies 
                                   SET Stock=@Stock, StockStatus=@StockStatus 
                                   WHERE Id=@Id AND SellerId=@SellerId";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Stock", Convert.ToInt32(txtEditStock.Text));
                    cmd.Parameters.AddWithValue("@StockStatus", ddlEditStockStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@Id", productId);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);

                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Stock updated successfully.", "alert-success");
                    }
                }

                gvProducts.EditIndex = -1;
                BindProductsWithPagination(productsPagination?.CurrentPage ?? 1, productsPagination?.PageSize ?? 10);
                LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error updating stock: {ex}");
                ShowMessage("Error updating stock.", "alert-danger");
            }
        }

        protected void gvProducts_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            try
            {
                hfActiveTab.Value = "products";
                int productId = Convert.ToInt32(gvProducts.DataKeys[e.RowIndex].Value);
                string sellerId = User.Identity.GetUserId();

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "DELETE FROM PetSupplies WHERE Id=@Id AND SellerId=@SellerId";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Id", productId);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);

                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Product deleted successfully.", "alert-success");
                    }
                    else
                    {
                        ShowMessage("Product not found or you don't have permission to delete it.", "alert-warning");
                    }
                }

                BindProductsWithPagination(productsPagination?.CurrentPage ?? 1, productsPagination?.PageSize ?? 10);
                LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error deleting product: {ex}");
                ShowMessage("Error deleting product. It may be referenced in existing orders.", "alert-danger");
            }
        }

        protected void btnAddProduct_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "add-product"; // Stay on add product tab

            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                string fileName = null;
                string sellerName = GetSellerName(sellerId);

                // Handle image upload
                if (fileAddImage.HasFile)
                {
                    string folderPath = Server.MapPath("~/Uploads/");
                    if (!System.IO.Directory.Exists(folderPath))
                        System.IO.Directory.CreateDirectory(folderPath);

                    fileName = "~/Uploads/" + Guid.NewGuid() + System.IO.Path.GetExtension(fileAddImage.FileName);
                    fileAddImage.SaveAs(Server.MapPath(fileName));
                }

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"INSERT INTO PetSupplies (SellerId, SellerName, Name, Description, Price, ImageUrl, Status, Stock, StockStatus)
                                    VALUES (@SellerId, @SellerName, @Name, @Description, @Price, @ImageUrl, 'Pending', @Stock, @StockStatus)";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    cmd.Parameters.AddWithValue("@SellerName", sellerName);
                    cmd.Parameters.AddWithValue("@Name", txtAddName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Description", txtAddDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@Price", Convert.ToDecimal(txtAddPrice.Text));
                    cmd.Parameters.AddWithValue("@ImageUrl", fileName ?? "");
                    cmd.Parameters.AddWithValue("@Stock", Convert.ToInt32(txtAddStock.Text));
                    cmd.Parameters.AddWithValue("@StockStatus", ddlAddStockStatus.SelectedValue);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Product added successfully and pending approval.", "alert-success");
                ClearAddForm();
                BindProductsWithPagination(1, productsPagination?.PageSize ?? 10);
                LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error adding product: {ex}");
                ShowMessage("Error: " + ex.Message, "alert-danger");
            }
        }

        protected void btnClearForm_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "add-product"; // Stay on add product tab
            ClearAddForm();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "products"; // Stay on products tab

            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                string fileName = null;
                bool isUpdate = !string.IsNullOrEmpty(hdnProductId.Value);
                string sellerName = GetSellerName(sellerId);

                // Handle image upload
                if (fileImage.HasFile)
                {
                    string folderPath = Server.MapPath("~/Uploads/");
                    if (!System.IO.Directory.Exists(folderPath))
                        System.IO.Directory.CreateDirectory(folderPath);

                    fileName = "~/Uploads/" + Guid.NewGuid() + System.IO.Path.GetExtension(fileImage.FileName);
                    fileImage.SaveAs(Server.MapPath(fileName));
                }

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query;
                    SqlCommand cmd;

                    if (isUpdate)
                    {
                        // Update existing product
                        query = @"UPDATE PetSupplies 
                                SET Name=@Name, Description=@Description, Price=@Price, 
                                    Stock=@Stock, StockStatus=@StockStatus" +
                                (fileName != null ? ", ImageUrl=@ImageUrl" : "") +
                                " WHERE Id=@Id AND SellerId=@SellerId";

                        cmd = new SqlCommand(query, con);
                        cmd.Parameters.AddWithValue("@Id", Convert.ToInt32(hdnProductId.Value));
                    }
                    else
                    {
                        // Insert new product
                        query = @"INSERT INTO PetSupplies (SellerId, SellerName, Name, Description, Price, ImageUrl, Status, Stock, StockStatus)
                                VALUES (@SellerId, @SellerName, @Name, @Description, @Price, @ImageUrl, 'Pending', @Stock, @StockStatus)";

                        cmd = new SqlCommand(query, con);
                        cmd.Parameters.AddWithValue("@ImageUrl", fileName ?? "");
                        cmd.Parameters.AddWithValue("@SellerName", sellerName);
                    }

                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@Price", Convert.ToDecimal(txtPrice.Text));
                    cmd.Parameters.AddWithValue("@Stock", Convert.ToInt32(txtStock.Text));
                    cmd.Parameters.AddWithValue("@StockStatus", ddlStockStatus.SelectedValue);

                    if (fileName != null && isUpdate)
                    {
                        cmd.Parameters.AddWithValue("@ImageUrl", fileName);
                    }

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage(isUpdate ? "Product updated successfully." : "Product added successfully and pending approval.", "alert-success");
                ClearEditForm();
                pnlEditProduct.Visible = false;
                BindProductsWithPagination(productsPagination?.CurrentPage ?? 1, productsPagination?.PageSize ?? 10);
                LoadStatistics();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error saving product: {ex}");
                ShowMessage("Error: " + ex.Message, "alert-danger");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "products"; // Stay on products tab
            ClearEditForm();
            pnlEditProduct.Visible = false;
        }

        #endregion

        #region Order Management

        protected void gvOrders_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewOrder")
            {
                hfActiveTab.Value = "orders"; // Stay on orders tab
                int orderId = Convert.ToInt32(e.CommandArgument);
                Response.Redirect($"~/OrderDetails.aspx?orderId={orderId}");
            }
        }

        #endregion

        #region Statistics

        private void LoadStatistics()
        {
            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // Total products
                    SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM PetSupplies WHERE SellerId=@SellerId", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblTotalProducts.Text = cmd.ExecuteScalar().ToString();

                    // Approved products
                    cmd = new SqlCommand("SELECT COUNT(*) FROM PetSupplies WHERE SellerId=@SellerId AND Status='Approved'", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblApprovedProducts.Text = cmd.ExecuteScalar().ToString();

                    // Pending products
                    cmd = new SqlCommand("SELECT COUNT(*) FROM PetSupplies WHERE SellerId=@SellerId AND Status='Pending'", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblPendingProducts.Text = cmd.ExecuteScalar().ToString();

                    // Rejected products
                    cmd = new SqlCommand("SELECT COUNT(*) FROM PetSupplies WHERE SellerId=@SellerId AND Status='Rejected'", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblRejectedProducts.Text = cmd.ExecuteScalar().ToString();

                    // Out of stock
                    cmd = new SqlCommand("SELECT COUNT(*) FROM PetSupplies WHERE SellerId=@SellerId AND StockStatus='Out of Stock'", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblOutOfStock.Text = cmd.ExecuteScalar().ToString();

                    // Total orders
                    cmd = new SqlCommand(@"
                        SELECT COUNT(DISTINCT oi.OrderId)
                        FROM OrderItems oi
                        INNER JOIN PetSupplies p ON oi.ProductId = p.Id
                        WHERE p.SellerId=@SellerId", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblTotalOrders.Text = cmd.ExecuteScalar().ToString();

                    // Total revenue
                    cmd = new SqlCommand(@"
                        SELECT ISNULL(SUM(oi.Quantity * oi.Price), 0)
                        FROM OrderItems oi
                        INNER JOIN PetSupplies p ON oi.ProductId = p.Id
                        INNER JOIN Orders o ON oi.OrderId = o.OrderId
                        WHERE p.SellerId=@SellerId AND o.Status != 'Cancelled'", con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);
                    lblTotalRevenue.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("0.00");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading statistics: {ex}");
            }
        }

        #endregion

        #region Helper Methods

        private string GetSellerName(string sellerId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "SELECT ISNULL(DisplayName, UserName) AS SellerName FROM AspNetUsers WHERE Id = @SellerId";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);

                    con.Open();
                    object result = cmd.ExecuteScalar();
                    return result?.ToString() ?? "Unknown Seller";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error getting seller name: {ex}");
                return "Unknown Seller";
            }
        }

        public string GetStockStatusBadge(string stockStatus)
        {
            switch (stockStatus?.ToLower())
            {
                case "in stock":
                    return "bg-success";
                case "out of stock":
                    return "bg-danger";
                case "limited stock":
                    return "bg-warning";
                default:
                    return "bg-secondary";
            }
        }

        public string GetStatusBadge(string status)
        {
            switch (status?.ToLower())
            {
                case "approved":
                    return "bg-success";
                case "pending":
                    return "bg-warning";
                case "rejected":
                    return "bg-danger";
                default:
                    return "bg-secondary";
            }
        }

        public string GetOrderStatusBadge(string status)
        {
            switch (status?.ToLower())
            {
                case "pending":
                    return "bg-warning";
                case "completed":
                    return "bg-success";
                case "cancelled":
                    return "bg-danger";
                default:
                    return "bg-secondary";
            }
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert {cssClass}";
            lblMessage.Visible = true;
        }

        private void ClearAddForm()
        {
            txtAddName.Text = "";
            txtAddDescription.Text = "";
            txtAddPrice.Text = "";
            txtAddStock.Text = "";
            ddlAddStockStatus.SelectedIndex = 0;
        }

        private void ClearEditForm()
        {
            hdnProductId.Value = "";
            txtName.Text = "";
            txtDescription.Text = "";
            txtPrice.Text = "";
            txtStock.Text = "";
            ddlStockStatus.SelectedIndex = 0;
            btnAdd.Text = "Update Product";
            litEditFormTitle.Text = "Edit Product";
        }

        private void LoadProductForEdit(int productId)
        {
            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT Id, Name, Description, Price, ImageUrl, 
                                   ISNULL(Stock, 0) as Stock, 
                                   ISNULL(StockStatus, 'In Stock') as StockStatus 
                                   FROM PetSupplies WHERE Id=@Id AND SellerId=@SellerId";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Id", productId);
                    cmd.Parameters.AddWithValue("@SellerId", sellerId);

                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnProductId.Value = productId.ToString();
                            txtName.Text = reader["Name"].ToString();
                            txtDescription.Text = reader["Description"].ToString();
                            txtPrice.Text = Convert.ToDecimal(reader["Price"]).ToString("0.00");
                            txtStock.Text = reader["Stock"].ToString();
                            ddlStockStatus.SelectedValue = reader["StockStatus"].ToString();

                            btnAdd.Text = "Update Product";
                            litEditFormTitle.Text = "Edit Product";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading product for edit: {ex}");
                ShowMessage("Error loading product details.", "alert-danger");
            }
        }

        #endregion

        #region Fallback Methods (for when pagination controls are not available)

        private void BindProductsFallback()
        {
            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"SELECT Id, Name, Description, Price, ImageUrl, Status, 
                                    ISNULL(Stock, 0) as Stock, 
                                    ISNULL(StockStatus, 'In Stock') as StockStatus 
                                    FROM PetSupplies WHERE SellerId=@SellerId";

                    string statusFilter = ddlStatusFilter.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        query += " AND Status=@Status";
                    }

                    query += " ORDER BY Id DESC";

                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    da.SelectCommand.Parameters.AddWithValue("@SellerId", sellerId);

                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        da.SelectCommand.Parameters.AddWithValue("@Status", statusFilter);
                    }

                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvProducts.DataSource = dt;
                    gvProducts.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error binding products (fallback): {ex}");
                ShowMessage("Error loading products.", "alert-danger");
            }
        }

        private void BindOrdersFallback()
        {
            string sellerId = User.Identity.GetUserId();
            if (string.IsNullOrEmpty(sellerId)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = @"
                        SELECT 
                            o.OrderId,
                            oi.ProductName,
                            oi.Quantity,
                            oi.Price,
                            (oi.Quantity * oi.Price) as TotalAmount,
                            o.CustomerName,
                            o.OrderDate,
                            o.Status as OrderStatus
                        FROM OrderItems oi
                        INNER JOIN Orders o ON oi.OrderId = o.OrderId
                        INNER JOIN PetSupplies p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @SellerId";

                    string statusFilter = ddlOrderStatusFilter.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        query += " AND o.Status = @Status";
                    }

                    query += " ORDER BY o.OrderDate DESC";

                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    da.SelectCommand.Parameters.AddWithValue("@SellerId", sellerId);

                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        da.SelectCommand.Parameters.AddWithValue("@Status", statusFilter);
                    }

                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvOrders.DataSource = dt;
                    gvOrders.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error binding orders (fallback): {ex}");
                ShowMessage("Error loading orders.", "alert-danger");
            }
        }

        #endregion
    }
}