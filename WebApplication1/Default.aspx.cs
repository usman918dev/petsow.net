using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;
using Microsoft.AspNet.Identity;

namespace WebApplication1
{
    public partial class _Default : Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFeaturedProducts();
                BindBestSellers();
               
            }
        }

        #region Product Binding Methods

        private void BindFeaturedProducts()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Get top 6 approved products (you can modify this logic to have a Featured flag)
                string query = @"SELECT TOP 6 * FROM PetSupplies 
                               WHERE Status = 'Approved' 
                               ORDER BY Id DESC";

                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptFeaturedProducts.DataSource = dt;
                    rptFeaturedProducts.DataBind();
                    lblNoFeaturedProducts.Visible = false;
                }
                else
                {
                    lblNoFeaturedProducts.Text = "No featured products available.";
                    lblNoFeaturedProducts.Visible = true;
                }
            }
        }

        private void BindBestSellers()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Get top 3 products based on order count (best sellers)
                // Explicitly select only the columns that exist instead of using p.*
                string query = @"SELECT TOP 3 
                                   p.Id, p.SellerId, p.SellerName, p.Name, p.Description, 
                                   p.Price, p.ImageUrl, p.Status, p.Stock, p.StockStatus,
                                   COUNT(oi.ProductId) as OrderCount
                               FROM PetSupplies p
                               LEFT JOIN OrderItems oi ON p.Id = oi.ProductId
                               WHERE p.Status = 'Approved'
                               GROUP BY p.Id, p.SellerId, p.SellerName, p.Name, p.Description, p.Price, p.ImageUrl, p.Status, p.Stock, p.StockStatus
                               ORDER BY OrderCount DESC, p.Id DESC";

                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptBestSellers.DataSource = dt;
                    rptBestSellers.DataBind();
                    lblNoBestSellers.Visible = false;
                }
                else
                {
                    lblNoBestSellers.Text = "No best sellers available.";
                    lblNoBestSellers.Visible = true;
                }
            }
        }

     
        #endregion

        #region Button Event Handlers

        protected void btnShopNow_Click(object sender, EventArgs e)
        {
            // Redirect to shop page instead of scrolling
            Response.Redirect("~/Shop.aspx");
        }

        protected void btnLearnMore_Click(object sender, EventArgs e)
        {
            // Redirect to Shop page or scroll to features
            Response.Redirect("~/Shop.aspx");
        }



        protected void btnStartShopping_Click(object sender, EventArgs e)
        {
            // Redirect to shop page instead of scrolling
            Response.Redirect("~/Shop.aspx");
        }

        protected void btnJoinNewsletter_Click(object sender, EventArgs e)
        {
            // Redirect to newsletter signup or show modal
            Response.Redirect("~/Default.aspx");
        }

        #endregion

        #region Add to Cart Handlers

        protected void btnAddToCart_Command(object sender, CommandEventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx");
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

        protected void btnAddToBestSellerCart_Command(object sender, CommandEventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx");
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

        protected void btnAddToAllProductsCart_Command(object sender, CommandEventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx");
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

        private void AddToCart(int productId)
        {
            try
            {
                string customerId = User.Identity.GetUserId();

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

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
                ShowMessage("Error adding product to cart: " + ex.Message, "alert-danger");
            }
        }

        #endregion

        #region Repeater Item Data Bound Events

        protected void rptFeaturedProducts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;

                // Image
                var img = (Image)e.Item.FindControl("imgFeaturedProduct");
                string imgUrl = drv["ImageUrl"] != DBNull.Value && !string.IsNullOrEmpty(drv["ImageUrl"].ToString())
                                ? drv["ImageUrl"].ToString()
                                : "https://via.placeholder.com/300x200?text=No+Image";
                img.ImageUrl = imgUrl;
                img.AlternateText = drv["Name"].ToString();

                // Description
                var lblDesc = (Label)e.Item.FindControl("lblFeaturedDescription");
                lblDesc.Text = TruncateDescription(drv["Description"].ToString(), 100);
            }
        }

        protected void rptBestSellers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;

                // Image
                var img = (Image)e.Item.FindControl("imgBestSellerProduct");
                string imgUrl = drv["ImageUrl"] != DBNull.Value && !string.IsNullOrEmpty(drv["ImageUrl"].ToString())
                                ? drv["ImageUrl"].ToString()
                                : "https://via.placeholder.com/300x200?text=No+Image";
                img.ImageUrl = imgUrl;
                img.AlternateText = drv["Name"].ToString();

                // Description
                var lblDesc = (Label)e.Item.FindControl("lblBestSellerDescription");
                lblDesc.Text = TruncateDescription(drv["Description"].ToString(), 100);
            }
        }

        protected void rptProducts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;

                // Image
                var img = (Image)e.Item.FindControl("imgProduct");
                string imgUrl = drv["ImageUrl"] != DBNull.Value && !string.IsNullOrEmpty(drv["ImageUrl"].ToString())
                                ? drv["ImageUrl"].ToString()
                                : "https://via.placeholder.com/300x200?text=No+Image";
                img.ImageUrl = imgUrl;
                img.AlternateText = drv["Name"].ToString();

                // Description
                var lblDesc = (Label)e.Item.FindControl("lblDescription");
                lblDesc.Text = TruncateDescription(drv["Description"].ToString(), 100);
            }
        }

        #endregion

        #region Helper Methods

        public string TruncateDescription(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return "";
            return text.Length <= maxLength ? text : text.Substring(0, maxLength) + "...";
        }

        private void ShowMessage(string message, string cssClass)
        {
            // You can add a message label to show notifications
            // For now, we'll use JavaScript alert
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowMessage", script, true);
        }

        #endregion
    }
}