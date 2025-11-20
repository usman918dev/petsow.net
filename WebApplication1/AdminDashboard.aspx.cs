using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using WebApplication1.Models;
using WebApplication1.Helpers;
using WebApplication1.Controls;

namespace WebApplication1
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        // Expose HiddenField declared in ASPX so <%=%> and code-behind can use it
        protected HiddenField hfActiveTab;

        // Manual control declarations (pagination user controls)
        protected Controls.PaginationControl productsPagination;
        protected Controls.PaginationControl usersPagination;
        protected Controls.PaginationControl ordersPagination;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify user is Admin
            if (!User.Identity.IsAuthenticated || !User.IsInRole("Admin"))
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Set default active tab
                hfActiveTab.Value = "products";

                LoadSellers();

                BindProductsWithPagination(1, 10);
                BindUsersWithPagination(1, 10);
                BindOrdersWithPagination(1, 10);
            }
        }

        #region Products Management

        private void LoadSellers()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Updated query to get seller names and IDs from both PetSupplies and AspNetUsers
                string query = @"
                    SELECT DISTINCT 
                        p.SellerId,
                        ISNULL(u.DisplayName, u.UserName) AS SellerName
                    FROM PetSupplies p
                    LEFT JOIN AspNetUsers u ON p.SellerId = u.Id
                    ORDER BY ISNULL(u.DisplayName, u.UserName)";

                SqlCommand cmd = new SqlCommand(query, con);
                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                ddlSellers.Items.Clear();
                ddlSellers.Items.Add(new ListItem("All Sellers", ""));
                while (reader.Read())
                {
                    string sellerId = reader["SellerId"].ToString();
                    string sellerName = reader["SellerName"].ToString();
                    ddlSellers.Items.Add(new ListItem(sellerName, sellerId));
                }
                con.Close();
            }
        }

        private void BindProducts()
        {
            string filterSeller = ddlSellers.SelectedValue;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // FIX: Changed alias to SellerDisplayName
                string query = @"
            SELECT 
                p.*,
                ISNULL(u.DisplayName, u.UserName) AS SellerDisplayName
            FROM PetSupplies p
            LEFT JOIN AspNetUsers u ON p.SellerId = u.Id";

                if (!string.IsNullOrEmpty(filterSeller))
                {
                    query += " WHERE p.SellerId=@SellerId";
                }

                query += " ORDER BY p.Id DESC";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(filterSeller))
                {
                    cmd.Parameters.AddWithValue("@SellerId", filterSeller);
                }

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvProducts.DataSource = dt;
                gvProducts.DataBind();
            }
        }

        private void BindProductsWithPagination(int pageIndex, int pageSize)
        {
            string filterSeller = ddlSellers.SelectedValue;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // FIX: Changed alias from 'SellerName' to 'SellerDisplayName' to avoid conflict with p.*
                string baseQuery = @"
            SELECT 
                p.*,
                ISNULL(u.DisplayName, u.UserName) AS SellerDisplayName
            FROM PetSupplies p
            LEFT JOIN AspNetUsers u ON p.SellerId = u.Id";

                if (!string.IsNullOrEmpty(filterSeller))
                {
                    baseQuery += " WHERE p.SellerId=@SellerId";
                }

                // The rest of your code remains exactly the same...
                string query = @"WITH PaginatedProducts AS (
                    SELECT *, ROW_NUMBER() OVER (ORDER BY Id DESC) as RowNum
                    FROM (" + baseQuery + @") AS ProductsData
                  )
                  SELECT * FROM PaginatedProducts
                  WHERE RowNum BETWEEN @Offset AND @Offset + @PageSize - 1;";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(filterSeller))
                {
                    cmd.Parameters.AddWithValue("@SellerId", filterSeller);
                }
                cmd.Parameters.AddWithValue("@Offset", (pageIndex - 1) * pageSize + 1);
                cmd.Parameters.AddWithValue("@PageSize", pageSize);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt); // The error happened here, now it will work.
                gvProducts.DataSource = dt;
                gvProducts.DataBind();

                // Update pagination control
                if (productsPagination != null)
                {
                    productsPagination.TotalRecords = GetProductCount(filterSeller);
                    productsPagination.CurrentPage = pageIndex;
                    productsPagination.PageSize = pageSize;
                }
            }
        }

        private int GetProductCount(string filterSeller)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT COUNT(*) FROM PetSupplies";

                if (!string.IsNullOrEmpty(filterSeller))
                {
                    query += " WHERE SellerId=@SellerId";
                }

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(filterSeller))
                {
                    cmd.Parameters.AddWithValue("@SellerId", filterSeller);
                }

                con.Open();
                int count = (int)cmd.ExecuteScalar();
                con.Close();

                return count;
            }
        }

        protected void gvProducts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Approve" || e.CommandName == "Reject")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                string newStatus = e.CommandName == "Approve" ? "Approved" : "Rejected";

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "UPDATE PetSupplies SET Status=@Status WHERE Id=@Id";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@Id", id);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }

                ShowMessage($"Product {newStatus} successfully.", "alert-success");
                BindProducts();
            }
        }

        protected void ddlSellers_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindProducts();
        }

        #endregion

        #region User Management

        private void BindUsers()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Updated query to join AspNetUsers with AspNetUserRoles and AspNetRoles to get display names and roles
                    string query = @"
                        SELECT DISTINCT
                            u.Id,
                            u.Email,
                            u.UserName,
                            ISNULL(u.DisplayName, u.UserName) AS DisplayName,
                            u.EmailConfirmed,
                            u.PhoneNumber,
                            u.LockoutEnabled,
                            ISNULL(r.Name, 'No Role') AS RoleName
                        FROM AspNetUsers u
                        LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
                        LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id";

                    // Filter by role if selected
                    string roleFilter = ddlRoleFilter.SelectedValue;
                    if (!string.IsNullOrEmpty(roleFilter))
                    {
                        query += " WHERE r.Name = @RoleFilter";
                    }

                    query += " ORDER BY u.Email";

                    SqlCommand cmd = new SqlCommand(query, con);
                    if (!string.IsNullOrEmpty(roleFilter))
                    {
                        cmd.Parameters.AddWithValue("@RoleFilter", roleFilter);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvUsers.DataSource = dt;
                    gvUsers.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error binding users: {ex}");
                ShowMessage("Error loading users.", "alert-danger");
            }
        }

        private void BindUsersWithPagination(int pageIndex, int pageSize)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Updated query to join AspNetUsers with AspNetUserRoles and AspNetRoles to get display names and roles
                string baseQuery = @"
                    SELECT DISTINCT
                        u.Id,
                        u.Email,
                        u.UserName,
                        ISNULL(u.DisplayName, u.UserName) AS DisplayName,
                        u.EmailConfirmed,
                        u.PhoneNumber,
                        u.LockoutEnabled,
                        ISNULL(r.Name, 'No Role') AS RoleName
                    FROM AspNetUsers u
                    LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
                    LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id";

                string roleFilter = ddlRoleFilter.SelectedValue;
                if (!string.IsNullOrEmpty(roleFilter))
                {
                    baseQuery += " WHERE r.Name = @RoleFilter";
                }

                // Fixed pagination logic
                string query = @"WITH PaginatedUsers AS (
                            SELECT *, ROW_NUMBER() OVER (ORDER BY Id) as RowNum
                            FROM (" + baseQuery + @") AS UsersData
                          )
                          SELECT * FROM PaginatedUsers
                          WHERE RowNum BETWEEN @Offset AND @Offset + @PageSize - 1;";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(roleFilter))
                {
                    cmd.Parameters.AddWithValue("@RoleFilter", roleFilter);
                }
                cmd.Parameters.AddWithValue("@Offset", (pageIndex - 1) * pageSize + 1);
                cmd.Parameters.AddWithValue("@PageSize", pageSize);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvUsers.DataSource = dt;
                gvUsers.DataBind();

                // Update pagination control
                if (usersPagination != null)
                {
                    usersPagination.TotalRecords = GetUserCount(roleFilter);
                    usersPagination.CurrentPage = pageIndex;
                    usersPagination.PageSize = pageSize;
                }
            }
        }

        private int GetUserCount(string roleFilter)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"SELECT COUNT(DISTINCT u.Id) 
                                 FROM AspNetUsers u
                                 LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
                                 LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id";

                if (!string.IsNullOrEmpty(roleFilter))
                {
                    query += " WHERE r.Name = @RoleFilter";
                }

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(roleFilter))
                {
                    cmd.Parameters.AddWithValue("@RoleFilter", roleFilter);
                }

                con.Open();
                int count = (int)cmd.ExecuteScalar();
                con.Close();

                return count;
            }
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                string userId = e.CommandArgument.ToString();
                LoadUserDetails(userId);
            }
        }

        protected void gvUsers_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvUsers.EditIndex = e.NewEditIndex;
            BindUsers();
        }

        protected void gvUsers_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvUsers.EditIndex = -1;
            BindUsers();
        }

        protected void gvUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                GridViewRow row = gvUsers.Rows[e.RowIndex];
                string userId = gvUsers.DataKeys[e.RowIndex].Value.ToString();

                CheckBox chkEmailConfirmed = (CheckBox)row.FindControl("chkEmailConfirmed");
                CheckBox chkLockoutEnabled = (CheckBox)row.FindControl("chkLockoutEnabled");

                var context = new ApplicationDbContext();
                var userManager = new UserManager<ApplicationUser>(new UserStore<ApplicationUser>(context));
                var user = userManager.FindById(userId);

                if (user != null)
                {
                    user.EmailConfirmed = chkEmailConfirmed.Checked;
                    user.LockoutEnabled = chkLockoutEnabled.Checked;

                    var result = userManager.Update(user);
                    if (result.Succeeded)
                    {
                        ShowMessage("User updated successfully.", "alert-success");
                    }
                    else
                    {
                        ShowMessage("Failed to update user.", "alert-danger");
                    }
                }

                gvUsers.EditIndex = -1;
                BindUsers();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error updating user: {ex}");
                ShowMessage("Error updating user.", "alert-danger");
            }
        }

        private void LoadUserDetails(string userId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Get user details including display name
                    string query = @"
                        SELECT 
                            u.Id,
                            u.Email,
                            u.UserName,
                            ISNULL(u.DisplayName, u.UserName) AS DisplayName,
                            u.EmailConfirmed,
                            u.LockoutEnabled,
                            u.PhoneNumber,
                            ISNULL(r.Name, 'No Role') AS RoleName
                        FROM AspNetUsers u
                        LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
                        LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
                        WHERE u.Id = @UserId";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    con.Open();

                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        lblUserId.Text = reader["Id"].ToString();
                        lblUserEmail.Text = reader["Email"].ToString();
                        lblUserName.Text = reader["DisplayName"].ToString();
                        lblEmailConfirmed.Text = Convert.ToBoolean(reader["EmailConfirmed"]) ? "Yes" : "No";
                        lblLockoutEnabled.Text = Convert.ToBoolean(reader["LockoutEnabled"]) ? "Yes" : "No";
                        lblPhoneNumber.Text = string.IsNullOrEmpty(reader["PhoneNumber"].ToString()) ? "Not provided" : reader["PhoneNumber"].ToString();
                        lblUserRole.Text = reader["RoleName"].ToString();

                        string roleName = reader["RoleName"].ToString();

                        // Load role-specific statistics
                        if (roleName == "Seller")
                        {
                            LoadSellerStatistics(userId);
                            pnlSellerStats.Visible = true;
                            pnlCustomerStats.Visible = false;
                        }
                        else if (roleName == "Customer")
                        {
                            LoadCustomerStatistics(userId);
                            pnlCustomerStats.Visible = true;
                            pnlSellerStats.Visible = false;
                        }
                        else
                        {
                            pnlSellerStats.Visible = false;
                            pnlCustomerStats.Visible = false;
                        }

                        pnlUserDetails.Visible = true;
                    }
                    con.Close();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading user details: {ex}");
                ShowMessage("Error loading user details.", "alert-danger");
            }
        }

        private void LoadSellerStatistics(string sellerId)
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
            }
        }

        private void LoadCustomerStatistics(string customerId)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // Total orders
                SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Orders WHERE CustomerId=@CustomerId", con);
                cmd.Parameters.AddWithValue("@CustomerId", customerId);
                lblTotalOrders.Text = cmd.ExecuteScalar().ToString();

                // Total spent
                cmd = new SqlCommand("SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE CustomerId=@CustomerId", con);
                cmd.Parameters.AddWithValue("@CustomerId", customerId);
                lblTotalSpent.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("0.00");

                // Last order date
                cmd = new SqlCommand("SELECT TOP 1 OrderDate FROM Orders WHERE CustomerId=@CustomerId ORDER BY OrderDate DESC", con);
                cmd.Parameters.AddWithValue("@CustomerId", customerId);
                var lastOrder = cmd.ExecuteScalar();
                lblLastOrderDate.Text = lastOrder != null ? Convert.ToDateTime(lastOrder).ToString("MMM dd, yyyy") : "N/A";
            }
        }

        protected void btnCloseUserDetails_Click(object sender, EventArgs e)
        {
            pnlUserDetails.Visible = false;
        }

        protected void ddlRoleFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindUsers();
        }

        public string GetRoleBadgeClass(string role)
        {
            switch (role?.ToLower())
            {
                case "admin":
                    return "bg-danger";
                case "seller":
                    return "bg-primary";
                case "customer":
                    return "bg-success";
                default:
                    return "bg-secondary";
            }
        }

        #endregion

        #region Order Management

        private void BindOrders()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string query = "SELECT OrderId, CustomerName, OrderDate, TotalAmount, Status, PaymentMethod FROM Orders";

                    string statusFilter = ddlOrderStatus.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        query += " WHERE Status=@Status";
                    }

                    query += " ORDER BY OrderDate DESC";

                    SqlCommand cmd = new SqlCommand(query, con);
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        cmd.Parameters.AddWithValue("@Status", statusFilter);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvOrders.DataSource = dt;
                    gvOrders.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error binding orders: {ex}");
                ShowMessage("Error loading orders.", "alert-danger");
            }
        }

        private void BindOrdersWithPagination(int pageIndex, int pageSize)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string baseQuery = "SELECT OrderId, CustomerName, OrderDate, TotalAmount, Status, PaymentMethod FROM Orders";

                string statusFilter = ddlOrderStatus.SelectedValue;
                if (!string.IsNullOrEmpty(statusFilter))
                {
                    baseQuery += " WHERE Status=@Status";
                }

                // Fixed pagination logic
                string query = @"WITH PaginatedOrders AS (
                            SELECT *, ROW_NUMBER() OVER (ORDER BY OrderDate DESC) as RowNum
                            FROM (" + baseQuery + @") AS OrdersData
                          )
                          SELECT * FROM PaginatedOrders
                          WHERE RowNum BETWEEN @Offset AND @Offset + @PageSize - 1;";

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(statusFilter))
                {
                    cmd.Parameters.AddWithValue("@Status", statusFilter);
                }
                cmd.Parameters.AddWithValue("@Offset", (pageIndex - 1) * pageSize + 1);
                cmd.Parameters.AddWithValue("@PageSize", pageSize);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvOrders.DataSource = dt;
                gvOrders.DataBind();

                // Update pagination control
                if (ordersPagination != null)
                {
                    ordersPagination.TotalRecords = GetOrderCount(statusFilter);
                    ordersPagination.CurrentPage = pageIndex;
                    ordersPagination.PageSize = pageSize;
                }
            }
        }

        private int GetOrderCount(string statusFilter)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT COUNT(*) FROM Orders";

                if (!string.IsNullOrEmpty(statusFilter))
                {
                    query += " WHERE Status=@Status";
                }

                SqlCommand cmd = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(statusFilter))
                {
                    cmd.Parameters.AddWithValue("@Status", statusFilter);
                }

                con.Open();
                int count = (int)cmd.ExecuteScalar();
                con.Close();

                return count;
            }
        }

        protected void gvOrders_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int orderId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ViewOrder")
            {
                Response.Redirect($"~/OrderDetails.aspx?orderId={orderId}");
            }
            else if (e.CommandName == "UpdateStatus")
            {
                // Handle dropdown status change - we'll implement this with RowDataBound
                BindOrders();
            }
            else if (e.CommandName == "MarkComplete")
            {
                UpdateOrderStatus(orderId, "Completed");
                ShowMessage("Order marked as completed.", "alert-success");
            }
            else if (e.CommandName == "CancelOrder")
            {
                UpdateOrderStatus(orderId, "Cancelled");
                ShowMessage("Order cancelled.", "alert-warning");
            }
        }

        protected void gvOrders_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Find the dropdown in the row
                DropDownList ddlOrderStatusUpdate = (DropDownList)e.Row.FindControl("ddlOrderStatusUpdate");
                if (ddlOrderStatusUpdate != null)
                {
                    // Populate dropdown options
                    ddlOrderStatusUpdate.Items.Clear();
                    ddlOrderStatusUpdate.Items.Add(new ListItem("Pending", "Pending"));
                    ddlOrderStatusUpdate.Items.Add(new ListItem("Processing", "Processing"));
                    ddlOrderStatusUpdate.Items.Add(new ListItem("Shipped", "Shipped"));
                    ddlOrderStatusUpdate.Items.Add(new ListItem("Delivered", "Delivered"));
                    ddlOrderStatusUpdate.Items.Add(new ListItem("Completed", "Completed"));
                    ddlOrderStatusUpdate.Items.Add(new ListItem("Cancelled", "Cancelled"));

                    // Set current status as selected
                    string currentStatus = ((DataRowView)e.Row.DataItem)["Status"].ToString();
                    ddlOrderStatusUpdate.SelectedValue = currentStatus;
                }
            }
        }

        protected void ddlOrderStatusUpdate_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl = (DropDownList)sender;
            GridViewRow row = (GridViewRow)ddl.NamingContainer;
            int orderId = Convert.ToInt32(gvOrders.DataKeys[row.RowIndex].Value);
            string newStatus = ddl.SelectedValue;

            UpdateOrderStatus(orderId, newStatus);
            ShowMessage($"Order #{orderId} status updated to {newStatus}.", "alert-success");
        }

        private void UpdateOrderStatus(int orderId, string status)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "UPDATE Orders SET Status=@Status WHERE OrderId=@OrderId";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@OrderId", orderId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            BindOrders();
        }

        protected void ddlOrderStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindOrders();
        }

        public string GetOrderStatusBadgeClass(string status)
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

        #endregion

        #region Pagination Event Handlers

        protected void productsPagination_PageChanged(object sender, PageChangedEventArgs e)
        {
            BindProductsWithPagination(e.CurrentPage, e.PageSize);
        }

        protected void productsPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
        {
            BindProductsWithPagination(1, e.PageSize);
        }

        protected void usersPagination_PageChanged(object sender, PageChangedEventArgs e)
        {
            BindUsersWithPagination(e.CurrentPage, e.PageSize);
        }

        protected void usersPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
        {
            BindUsersWithPagination(1, e.PageSize);
        }

        protected void ordersPagination_PageChanged(object sender, PageChangedEventArgs e)
        {
            BindOrdersWithPagination(e.CurrentPage, e.PageSize);
        }

        protected void ordersPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
        {
            BindOrdersWithPagination(1, e.PageSize);
        }

        #endregion

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert {cssClass}";
            lblMessage.Visible = true;
        }
    }
}
