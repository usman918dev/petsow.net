using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.AspNet.Identity;
using WebApplication1.Helpers;

namespace WebApplication1
{
    public partial class Shop : Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        private const int ProductsPerPage = 9;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Get search term from query string if available
                string searchTerm = Request.QueryString["search"];
                if (!string.IsNullOrEmpty(searchTerm))
                {
                    txtSearch.Text = searchTerm;
                }

                // Get price range from query string if available
                string priceRange = Request.QueryString["priceRange"];
                if (!string.IsNullOrEmpty(priceRange))
                {
                    ddlPriceRange.SelectedValue = priceRange;
                }

                // Get custom price range from query string if available
                string minPrice = Request.QueryString["minPrice"];
                string maxPrice = Request.QueryString["maxPrice"];
                if (!string.IsNullOrEmpty(minPrice))
                {
                    txtMinPrice.Text = minPrice;
                }
                if (!string.IsNullOrEmpty(maxPrice))
                {
                    txtMaxPrice.Text = maxPrice;
                }

                // Get page number from query string
                int currentPage = 1;
                if (int.TryParse(Request.QueryString["page"], out int pageFromUrl))
                {
                    currentPage = pageFromUrl;
                }

                LoadProducts(currentPage, txtSearch.Text.Trim(), GetPriceRangeFromControls());
            }
        }

        #region Product Loading with Pagination

        private void LoadProducts(int currentPage, string searchTerm = "", PriceRange priceRange = null)
        {
            try
            {
                // Validate pagination parameters
                int pageSize = ProductsPerPage;
                PaginationHelper.ValidatePaginationParams(ref currentPage, ref pageSize);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Build the base query
                    string baseQuery = @"
                        SELECT Id, Name, Description, Price, ImageUrl, Stock, StockStatus 
                        FROM PetSupplies 
                        WHERE Status = 'Approved'";

                    string countQuery = @"
                        SELECT COUNT(*) 
                        FROM PetSupplies 
                        WHERE Status = 'Approved'";

                    // Add search filter if provided
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        string searchFilter = " AND Name LIKE @SearchTerm";
                        baseQuery += searchFilter;
                        countQuery += searchFilter;
                    }

                    // Add price range filter if provided
                    if (priceRange != null && (priceRange.MinPrice.HasValue || priceRange.MaxPrice.HasValue))
                    {
                        if (priceRange.MinPrice.HasValue && priceRange.MaxPrice.HasValue)
                        {
                            string priceFilter = " AND Price BETWEEN @MinPrice AND @MaxPrice";
                            baseQuery += priceFilter;
                            countQuery += priceFilter;
                        }
                        else if (priceRange.MinPrice.HasValue)
                        {
                            string priceFilter = " AND Price >= @MinPrice";
                            baseQuery += priceFilter;
                            countQuery += priceFilter;
                        }
                        else if (priceRange.MaxPrice.HasValue)
                        {
                            string priceFilter = " AND Price <= @MaxPrice";
                            baseQuery += priceFilter;
                            countQuery += priceFilter;
                        }
                    }

                    // Get total count
                    int totalRecords = 0;
                    using (SqlCommand countCmd = new SqlCommand(countQuery, con))
                    {
                        if (!string.IsNullOrEmpty(searchTerm))
                        {
                            countCmd.Parameters.AddWithValue("@SearchTerm", "%" + searchTerm + "%");
                        }

                        if (priceRange != null)
                        {
                            if (priceRange.MinPrice.HasValue)
                            {
                                countCmd.Parameters.AddWithValue("@MinPrice", priceRange.MinPrice.Value);
                            }
                            if (priceRange.MaxPrice.HasValue)
                            {
                                countCmd.Parameters.AddWithValue("@MaxPrice", priceRange.MaxPrice.Value);
                            }
                        }

                        con.Open();
                        totalRecords = (int)countCmd.ExecuteScalar();
                        con.Close();
                    }

                    // Calculate pagination
                    int totalPages = (int)Math.Ceiling((double)totalRecords / ProductsPerPage);
                    currentPage = Math.Max(1, Math.Min(currentPage, totalPages));

                    // Build final query with pagination
                    string finalQuery = baseQuery + @"
                        ORDER BY Id DESC
                        OFFSET @Offset ROWS
                        FETCH NEXT @PageSize ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(finalQuery, con))
                    {
                        if (!string.IsNullOrEmpty(searchTerm))
                        {
                            cmd.Parameters.AddWithValue("@SearchTerm", "%" + searchTerm + "%");
                        }

                        if (priceRange != null)
                        {
                            if (priceRange.MinPrice.HasValue)
                            {
                                cmd.Parameters.AddWithValue("@MinPrice", priceRange.MinPrice.Value);
                            }
                            if (priceRange.MaxPrice.HasValue)
                            {
                                cmd.Parameters.AddWithValue("@MaxPrice", priceRange.MaxPrice.Value);
                            }
                        }
                        
                        cmd.Parameters.AddWithValue("@Offset", (currentPage - 1) * ProductsPerPage);
                        cmd.Parameters.AddWithValue("@PageSize", ProductsPerPage);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Bind data
                        if (dt.Rows.Count > 0)
                        {
                            rptProducts.DataSource = dt;
                            rptProducts.DataBind();
                            pnlNoProducts.Visible = false;
                        }
                        else
                        {
                            rptProducts.DataSource = null;
                            rptProducts.DataBind();
                            pnlNoProducts.Visible = true;
                            
                            string noProductsMessage = "No products found";
                            if (!string.IsNullOrEmpty(searchTerm))
                            {
                                noProductsMessage += $" matching '{searchTerm}'";
                            }
                            if (priceRange != null && (priceRange.MinPrice.HasValue || priceRange.MaxPrice.HasValue))
                            {
                                noProductsMessage += $" in the specified price range";
                            }
                            noProductsMessage += ".";
                            
                            lblNoProductsMessage.Text = noProductsMessage;
                        }

                        // Update results information
                        UpdateResultsInfo(totalRecords, currentPage, searchTerm, priceRange);

                        // Configure pagination
                        SetupPagination(currentPage, totalPages, totalRecords, searchTerm, priceRange);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error in LoadProducts: {ex}");
                ShowErrorMessage("An error occurred while loading products. Please try again.");
            }
        }

        private void UpdateResultsInfo(int totalRecords, int currentPage, string searchTerm, PriceRange priceRange = null)
        {
            int startRecord = Math.Min((currentPage - 1) * ProductsPerPage + 1, totalRecords);
            int endRecord = Math.Min(currentPage * ProductsPerPage, totalRecords);

            string resultsText;
            if (totalRecords == 0)
            {
                resultsText = "No products found";
            }
            else
            {
                resultsText = $"Showing {startRecord}-{endRecord} of {totalRecords} products";
            }

            // Add search term info
            if (!string.IsNullOrEmpty(searchTerm))
            {
                resultsText += $" for '{searchTerm}'";
            }

            // Add price range info
            if (priceRange != null && (priceRange.MinPrice.HasValue || priceRange.MaxPrice.HasValue))
            {
                string priceInfo = "";
                if (priceRange.MinPrice.HasValue && priceRange.MaxPrice.HasValue)
                {
                    priceInfo = $" in price range ${priceRange.MinPrice:0.00} - ${priceRange.MaxPrice:0.00}";
                }
                else if (priceRange.MinPrice.HasValue)
                {
                    priceInfo = $" with price above ${priceRange.MinPrice:0.00}";
                }
                else if (priceRange.MaxPrice.HasValue)
                {
                    priceInfo = $" with price below ${priceRange.MaxPrice:0.00}";
                }
                resultsText += priceInfo;
            }

            lblResultsInfo.Text = resultsText;
        }

        private void SetupPagination(int currentPage, int totalPages, int totalRecords, string searchTerm, PriceRange priceRange = null)
        {
            try
            {
                // Configure pagination control using the correct method signature
                productsPagination.SetPaginationData(totalRecords, currentPage, ProductsPerPage);
                productsPagination.Visible = totalPages > 1;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error in SetupPagination: {ex}");
                productsPagination.Visible = false;
            }
        }

        #endregion

        #region Event Handlers

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchTerm = txtSearch.Text.Trim();
            var priceRange = GetPriceRangeFromControls();
            
            // Build redirect URL with all parameters
            string redirectUrl = BuildRedirectUrl(searchTerm, priceRange, 1);
            Response.Redirect(redirectUrl);
        }

        protected void btnApplyCustomRange_Click(object sender, EventArgs e)
        {
            string searchTerm = txtSearch.Text.Trim();
            
            // Clear dropdown selection when using custom range
            ddlPriceRange.SelectedValue = "";
            
            var priceRange = GetCustomPriceRange();
            
            // Build redirect URL with all parameters
            string redirectUrl = BuildRedirectUrl(searchTerm, priceRange, 1);
            Response.Redirect(redirectUrl);
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            Response.Redirect("Shop.aspx");
        }

        protected void productsPagination_PageChanged(object sender, EventArgs e)
        {
            // Get the pagination control
            var paginationControl = sender as Controls.PaginationControl;
            if (paginationControl != null)
            {
                // Reload products with the new page
                LoadProducts(paginationControl.CurrentPage, txtSearch.Text.Trim(), GetPriceRangeFromControls());
            }
        }

        protected void btnAddToCart_Command(object sender, CommandEventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                string returnUrl = Request.Url.ToString();
                Response.Redirect($"~/Account/Login.aspx?ReturnUrl={Server.UrlEncode(returnUrl)}");
                return;
            }

            if (!User.IsInRole("Customer"))
            {
                ShowMessage("Only customers can add items to cart.", "alert-warning");
                return;
            }

            int productId = Convert.ToInt32(e.CommandArgument);
            AddToCart(productId);
        }

        protected void rptProducts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;

                // Set product image
                var img = (Image)e.Item.FindControl("imgProduct");
                string imgUrl = drv["ImageUrl"] != DBNull.Value && !string.IsNullOrEmpty(drv["ImageUrl"].ToString())
                                ? drv["ImageUrl"].ToString()
                                : "https://via.placeholder.com/300x250?text=No+Image";
                img.ImageUrl = imgUrl;
                img.AlternateText = drv["Name"].ToString();

                // Set description (truncated)
                var lblDesc = (Label)e.Item.FindControl("lblDescription");
                lblDesc.Text = TruncateDescription(drv["Description"].ToString(), 100);
            }
        }

        #endregion

        #region Helper Methods

        private void AddToCart(int productId)
        {
            try
            {
                string customerId = User.Identity.GetUserId();

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // First, check if product is still in stock
                    string stockQuery = "SELECT Stock FROM PetSupplies WHERE Id = @ProductId";
                    using (SqlCommand stockCmd = new SqlCommand(stockQuery, con))
                    {
                        stockCmd.Parameters.AddWithValue("@ProductId", productId);
                        object stockResult = stockCmd.ExecuteScalar();
                        
                        if (stockResult == null || Convert.ToInt32(stockResult) <= 0)
                        {
                            ShowMessage("Sorry, this product is out of stock.", "alert-warning");
                            return;
                        }
                    }

                    // Check if item already exists in cart
                    string checkQuery = "SELECT Quantity FROM Cart WHERE CustomerId=@CustomerId AND ProductId=@ProductId";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, con);
                    checkCmd.Parameters.AddWithValue("@CustomerId", customerId);
                    checkCmd.Parameters.AddWithValue("@ProductId", productId);

                    object existingQuantity = checkCmd.ExecuteScalar();

                    if (existingQuantity != null)
                    {
                        // Update quantity
                        string updateQuery = "UPDATE Cart SET Quantity = Quantity + 1 WHERE CustomerId=@CustomerId AND ProductId=@ProductId";
                        SqlCommand updateCmd = new SqlCommand(updateQuery, con);
                        updateCmd.Parameters.AddWithValue("@CustomerId", customerId);
                        updateCmd.Parameters.AddWithValue("@ProductId", productId);
                        updateCmd.ExecuteNonQuery();
                    }
                    else
                    {
                        // Insert new cart item
                        string insertQuery = @"INSERT INTO Cart (CustomerId, ProductId, Quantity, DateAdded) 
                                             VALUES (@CustomerId, @ProductId, 1, GETDATE())";
                        SqlCommand insertCmd = new SqlCommand(insertQuery, con);
                        insertCmd.Parameters.AddWithValue("@CustomerId", customerId);
                        insertCmd.Parameters.AddWithValue("@ProductId", productId);
                        insertCmd.ExecuteNonQuery();
                    }
                }

                ShowMessage("Product added to cart successfully!", "alert-success");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error in AddToCart: {ex}");
                ShowMessage("Error adding product to cart: " + ex.Message, "alert-danger");
            }
        }

        private string TruncateDescription(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return "";
            return text.Length <= maxLength ? text : text.Substring(0, maxLength) + "...";
        }

        private void ShowMessage(string message, string cssClass)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage", script, true);
        }

        private void ShowErrorMessage(string message)
        {
            lblResultsInfo.Text = $"<div class='alert alert-danger'>{message}</div>";
        }

        private PriceRange GetPriceRangeFromControls()
        {
            // First check if dropdown has a selection
            if (!string.IsNullOrEmpty(ddlPriceRange.SelectedValue))
            {
                return ParseDropdownPriceRange(ddlPriceRange.SelectedValue);
            }

            // Then check custom price range
            return GetCustomPriceRange();
        }

        private PriceRange GetCustomPriceRange()
        {
            var priceRange = new PriceRange();
            
            if (decimal.TryParse(txtMinPrice.Text, out decimal minPrice))
            {
                priceRange.MinPrice = minPrice;
            }
            
            if (decimal.TryParse(txtMaxPrice.Text, out decimal maxPrice))
            {
                priceRange.MaxPrice = maxPrice;
            }

            return priceRange;
        }

        private PriceRange ParseDropdownPriceRange(string rangeValue)
        {
            var priceRange = new PriceRange();
            
            if (string.IsNullOrEmpty(rangeValue))
                return priceRange;

            var parts = rangeValue.Split('-');
            if (parts.Length == 2)
            {
                if (decimal.TryParse(parts[0], out decimal min))
                {
                    priceRange.MinPrice = min;
                }
                
                if (decimal.TryParse(parts[1], out decimal max))
                {
                    priceRange.MaxPrice = max;
                }
            }

            return priceRange;
        }

        private string BuildRedirectUrl(string searchTerm, PriceRange priceRange, int page)
        {
            var url = "Shop.aspx?page=" + page;
            
            if (!string.IsNullOrEmpty(searchTerm))
            {
                url += "&search=" + Server.UrlEncode(searchTerm);
            }
            
            if (priceRange != null)
            {
                if (priceRange.MinPrice.HasValue)
                {
                    url += "&minPrice=" + priceRange.MinPrice.Value;
                }
                if (priceRange.MaxPrice.HasValue)
                {
                    url += "&maxPrice=" + priceRange.MaxPrice.Value;
                }
            }

            return url;
        }

        #endregion
    }

    // Helper class for price range
    public class PriceRange
    {
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
    }
}