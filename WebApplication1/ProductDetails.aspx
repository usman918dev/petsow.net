<%@ Page Title="Product Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProductDetails.aspx.cs" Inherits="WebApplication1.ProductDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        /* 1. Product Page Background */
        .product-page {
            background-color: #f8f9fa;
            min-height: 90vh;
            padding-top: 2rem;
        }

        /* 2. Image Container - The Ratio Fix */
        .product-image-wrapper {
            width: 100%;
            height: 500px; /* Fixed height for desktop */
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            border-right: 1px solid #eee; /* subtle separator */
            padding: 20px;
        }

        /* 3. The Image Itself */
        .product-image-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: contain; /* KEY FIX: Shows whole image without stretching */
            transition: transform 0.3s ease;
        }

        /* Optional: Zoom effect on hover */
        .product-image-wrapper:hover img {
            transform: scale(1.05);
        }

        /* 4. Details Section styling */
        .product-details {
            padding: 3rem;
        }

        .price-tag {
            font-size: 2rem;
            font-weight: 700;
            color: #212529;
        }

        /* Mobile Responsiveness */
        @media (max-width: 768px) {
            .product-image-wrapper {
                height: 300px; /* Smaller height for mobile */
                border-right: none;
                border-bottom: 1px solid #eee;
            }
            .product-details {
                padding: 1.5rem;
            }
        }
    </style>

    <div class="product-page">
        <div class="container">
            
            <div class="mb-3">
                <a href="Shop.aspx" class="text-decoration-none text-muted">
                    <i class="fas fa-arrow-left me-1"></i> Back to Shop
                </a>
            </div>

            <div class="card shadow-sm border-0 overflow-hidden mb-5">
                <div class="row g-0"> <div class="col-md-6 bg-white">
                        <div class="product-image-wrapper">
                            <asp:Image ID="imgProduct" runat="server" />
                        </div>
                    </div>

                    <div class="col-md-6 bg-white">
                        <div class="product-details h-100 d-flex flex-column justify-content-center">
                            
                            <h1 class="fw-bold mb-2">
                                <asp:Label ID="lblProductName" runat="server"></asp:Label>
                            </h1>

                            <div class="mb-3 text-warning small">
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star-half-alt"></i>
                                <span class="text-muted ms-2">(Customer Review)</span>
                            </div>

                            <div class="mb-4">
                                <span class="price-tag">$<asp:Label ID="lblPrice" runat="server"></asp:Label></span>
                            </div>

                            <div class="mb-4">
                                <h5 class="fw-bold text-uppercase small text-muted ls-1">Description</h5>
                                <p class="text-secondary" style="line-height: 1.6;">
                                    <asp:Label ID="lblDescription" runat="server"></asp:Label>
                                </p>
                            </div>

                            <ul class="list-unstyled mb-4 text-muted small">
                                <li class="mb-1"><i class="fas fa-check text-success me-2"></i>In Stock & Ready to Ship</li>
                                <li class="mb-1"><i class="fas fa-shield-alt text-primary me-2"></i>Quality Guarantee</li>
                            </ul>

                            <hr class="my-4 opacity-25">

                            <div class="d-flex align-items-center gap-3">
                                <asp:Button ID="btnBuy" runat="server" Text="Add to Cart" 
                                    CssClass="btn btn-dark btn-lg px-5 rounded-pill shadow-sm flex-grow-1" 
                                    OnClick="btnBuy_Click" />

                            </div>

                            <div class="mt-3">
                                <asp:Label ID="lblError" runat="server" CssClass="text-danger small fw-bold" Visible="false"></asp:Label>
                            </div>

                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>