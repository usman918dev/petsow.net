using System;
using System.Data.SqlClient;
using System.Web.UI;
using WebApplication1.Helpers;
using Microsoft.AspNet.Identity;

namespace WebApplication1
{
    public partial class ProductDetails : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProductDetails();
                CheckUserRole();
            }
        }

        private void CheckUserRole()
        {
            // Check if user is logged in
            if (!User.Identity.IsAuthenticated)
            {
                btnBuy.Enabled = false;
                btnBuy.Text = "Login to Purchase";
                btnBuy.ToolTip = "You must be logged in as a Customer to purchase products";
                return;
            }

            // Check if user is a Customer
            if (!User.IsInRole("Customer"))
            {
                btnBuy.Enabled = false;
                btnBuy.Text = "Customers Only";
                btnBuy.ToolTip = "Only customers can purchase products";
                
                if (User.IsInRole("Seller"))
                {
                    ShowError("Sellers cannot purchase products. Please register as a Customer to make purchases.");
                }
            }
        }

        private void LoadProductDetails()
        {
            try
            {
                string productId = Request.QueryString["id"]?.Trim();

                // Validate product ID
                if (string.IsNullOrEmpty(productId) || !int.TryParse(productId, out _))
                {
                    ShowError("Invalid or missing product ID.");
                    btnBuy.Enabled = false;
                    return;
                }

                var product = GetProductById(productId);

                if (product == null)
                {
                    ShowError("Product not found.");
                    btnBuy.Enabled = false;
                    return;
                }

                // Populate UI fields
                lblProductName.Text = product.Name;
                lblPrice.Text = product.Price.ToString("0.00");
                lblDescription.Text = product.Description;
                imgProduct.ImageUrl = product.ImageUrl;
                Title = $"{product.Name} - Pet Store";
            }
            catch (Exception ex)
            {
                // Log for developers
                System.Diagnostics.Trace.TraceError($"Unexpected error in LoadProductDetails: {ex}");
                ShowError("An error occurred while loading the product details.");
                btnBuy.Enabled = false;
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }

        protected void btnBuy_Click(object sender, EventArgs e)
        {
            try
            {
                // Verify user is authenticated and is a Customer
                if (!User.Identity.IsAuthenticated)
                {
                    Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl));
                    return;
                }

                if (!User.IsInRole("Customer"))
                {
                    ShowError("Only customers can purchase products. Please register as a Customer.");
                    return;
                }

                string productId = Request.QueryString["id"]?.Trim();
                
                if (string.IsNullOrEmpty(productId) || !int.TryParse(productId, out int id))
                {
                    ShowError("Invalid product.");
                    return;
                }

                // Get product details from database
                var product = GetProductById(productId);
                
                if (product == null)
                {
                    ShowError("Product not found.");
                    return;
                }

                // Add to cart
                CartHelper.AddToCart(Session, id, product.Name, product.Price, product.ImageUrl);

                // Redirect to cart page
                Response.Redirect("~/Cart.aspx");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error in btnBuy_Click: {ex}");
                ShowError("Unable to add the product to the cart. Please try again.");
            }
        }

        private Product GetProductById(string id)
        {
            Product product = null;

            string connectionString = System.Configuration.ConfigurationManager
                .ConnectionStrings["DefaultConnection"].ConnectionString;

            const string query = @"
                SELECT Name, Price, Description, ImageUrl
                FROM PetSupplies
                WHERE Id = @Id
            ";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            product = new Product
                            {
                                Name = reader["Name"].ToString(),
                                Price = Convert.ToDecimal(reader["Price"]),
                                Description = reader["Description"].ToString(),
                                ImageUrl = reader["ImageUrl"].ToString()
                            };
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Database error in GetProductById({id}): {ex}");
            }

            return product;
        }

        // ? Strongly typed Product model for cleaner code
        private class Product
        {
            public string Name { get; set; }
            public decimal Price { get; set; }
            public string Description { get; set; }
            public string ImageUrl { get; set; }
        }
    }
}
