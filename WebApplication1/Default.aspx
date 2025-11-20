<%@ Page Title="Pet Store Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="WebApplication1._Default" %>

    <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

        <style>
            :root {
                --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                --primary-color: #764ba2;
                --accent-color: #667eea;
            }

            /* General Styling */
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                /* Ensure clean font */
            }

            .section-header {
                margin-bottom: 3rem;
                position: relative;
            }

            .section-header h2 {
                font-weight: 700;
                color: #333;
            }

            /* Utility class to truncate text after specific lines */
            .text-clamp-2 {
                display: -webkit-box;
                -webkit-line-clamp: 2;
                /* Limits to 2 lines */
                -webkit-box-orient: vertical;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .section-header p {
                color: #6c757d;
                max-width: 600px;
                margin: 0 auto;
            }

            /* Hero Section */
            .hero-section {
                background: var(--primary-gradient);
                color: white;
                margin-top: -30px;
                padding-top: 100px;
                padding-bottom: 140px;
                /* Extra space for the wave */
                position: relative;
                overflow: hidden;
                width: 100vw;
                margin-left: -50vw;
                left: 50%;
            }

            /* SVG Wave Separator */
            .custom-shape-divider-bottom {
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                overflow: hidden;
                line-height: 0;
                transform: rotate(180deg);
            }

            .custom-shape-divider-bottom svg {
                position: relative;
                display: block;
                width: calc(100% + 1.3px);
                height: 60px;
            }

            .custom-shape-divider-bottom .shape-fill {
                fill: #FFFFFF;
            }

            /* Feature Cards */
            .feature-card {
                border: none;
                border-radius: 15px;
                transition: all 0.3s ease;
                background: #fff;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
                padding: 2rem 1rem;
            }

            .feature-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            }

            .icon-box {
                width: 80px;
                height: 80px;
                line-height: 80px;
                border-radius: 50%;
                background: rgba(118, 75, 162, 0.1);
                color: var(--primary-color);
                font-size: 2rem;
                margin: 0 auto 1.5rem auto;
                transition: all 0.3s ease;
            }

            .feature-card:hover .icon-box {
                background: var(--primary-gradient);
                color: white;
            }

            /* Product Cards */
            .product-card {
                border: none;
                border-radius: 16px;
                overflow: hidden;
                transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
                background: #fff;
            }

            .product-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
            }

            .product-img-wrapper {
                overflow: hidden;
                position: relative;
                height: 240px;
            }

            .card-img-top {
                transition: transform 0.5s ease;
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .product-card:hover .card-img-top {
                transform: scale(1.05);
            }

            .badge-custom {
                background: rgba(255, 255, 255, 0.9);
                color: var(--primary-color);
                font-weight: 700;
                padding: 8px 16px;
                border-radius: 30px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                backdrop-filter: blur(5px);
            }

            .card-title a {
                color: #2d3748;
                font-weight: 600;
                transition: color 0.2s;
            }

            .card-title a:hover {
                color: var(--accent-color);
            }

            .product-price {
                font-size: 1.25rem;
                font-weight: 700;
                color: var(--primary-color);
            }

            .btn-custom-cart {
                background: #fff;
                border: 2px solid #e2e8f0;
                color: #4a5568;
                border-radius: 50px;
                padding: 8px 20px;
                font-weight: 600;
                transition: all 0.3s;
                text-decoration: none;
            }

            .btn-custom-cart:hover {
                background: var(--primary-gradient);
                border-color: transparent;
                color: white;
            }

            /* Stats & Testimonials */
            .stats-section {
                background: #f8f9fa;
                border-radius: 20px;
                margin: 4rem auto;
            }

            .testimonial-section {
                background: var(--primary-gradient);
                color: white;
                position: relative;
                width: 100vw;
                margin-left: -50vw;
                left: 50%;
            }

            .testimonial-card {
                background: rgba(255, 255, 255, 0.1);
                border: 1px solid rgba(255, 255, 255, 0.2);
                backdrop-filter: blur(10px);
                border-radius: 15px;
            }

            /* CTA */
            .cta-section {
                background: #2d3748;
                border-radius: 20px;
                margin-top: 20px;

            }
        </style>

        <section class="hero-section">
            <div class="container position-relative z-1">
                <div class="row align-items-center">
                    <div class="col-lg-6 mb-5 mb-lg-0">
                        <span class="badge bg-white text-primary rounded-pill px-3 py-2 mb-3 fw-bold shadow-sm">
                            <i class="fas fa-heart me-1"></i> #1 Pet Shop
                        </span>
                        <h1 class="display-3 fw-bold mb-4 lh-sm">Everything Your <br />Pet Needs</h1>
                        <p class="lead mb-5 opacity-75" style="max-width: 90%;">Discover premium pet supplies, toys,
                            accessories, and nutritious feeds. We deliver happiness to your doorstep.</p>
                        <div class="d-flex flex-wrap gap-3">
                            <asp:Button ID="btnShopNow" runat="server" Text="Shop Now"
                                CssClass="btn btn-light rounded-pill px-5 py-3 fw-bold shadow-sm"
                                OnClick="btnShopNow_Click" />
                            <asp:Button ID="btnLearnMore" runat="server" Text="Learn More"
                                CssClass="btn btn-outline-light rounded-pill px-5 py-3 fw-bold"
                                OnClick="btnLearnMore_Click" />
                        </div>
                    </div>
                    <div class="col-lg-6 text-center">
                        <div class="position-relative d-inline-block">
                            <div
                                style="position: absolute; width: 300px; height: 300px; background: rgba(255,255,255,0.1); border-radius: 50%; top: 50%; left: 50%; transform: translate(-50%, -50%); filter: blur(40px);">
                            </div>
                            <i class="fas fa-paw"
                                style="font-size: 10rem; color: rgba(255,255,255,0.8); position: relative; animation: float 3s ease-in-out infinite;"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="custom-shape-divider-bottom">
                <svg data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120"
                    preserveAspectRatio="none">
                    <path
                        d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"
                        class="shape-fill"></path>
                </svg>
            </div>
        </section>

        <section class="py-5">
            <div class="container py-4">
                <div class="section-header text-center">
                    <h2 class="display-6">Why Choose Us?</h2>
                    <p class="fs-5">We're committed to providing the best for your beloved pets</p>
                </div>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="card feature-card h-100 text-center">
                            <div class="card-body">
                                <div class="icon-box">
                                    <i class="fas fa-award"></i>
                                </div>
                                <h4 class="fw-bold mb-3">Premium Quality</h4>
                                <p class="text-muted">Only the finest products from trusted brands for your pet's safety
                                    and happiness.</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card feature-card h-100 text-center">
                            <div class="card-body">
                                <div class="icon-box">
                                    <i class="fas fa-shipping-fast"></i>
                                </div>
                                <h4 class="fw-bold mb-3">Fast Delivery</h4>
                                <p class="text-muted">Quick and secure delivery to your doorstep. Your pet won't have to
                                    wait long!</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card feature-card h-100 text-center">
                            <div class="card-body">
                                <div class="icon-box">
                                    <i class="fas fa-heart"></i>
                                </div>
                                <h4 class="fw-bold mb-3">Pet Care Experts</h4>
                                <p class="text-muted">Our team of pet care experts is here to help you choose the best
                                    products.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="py-5 bg-light">
            <div class="container py-4">
                <div class="section-header text-center mb-5">
                    <h2 class="display-6 fw-bold text-dark">Featured Products</h2>
                    <p class="fs-5 text-muted">Our most popular items that pets and their owners love</p>
                </div>

                <div class="row g-4" id="featuredProducts">
                    <asp:Repeater ID="rptFeaturedProducts" runat="server"
                        OnItemDataBound="rptFeaturedProducts_ItemDataBound">
                        <ItemTemplate>
                            <div class="col-lg-4 col-md-6">
                                <div class="card product-card h-100 border-0 shadow-sm">

                                    <div class="product-img-wrapper position-relative">
                                        <asp:HyperLink ID="lnkFeaturedProduct" runat="server"
                                            NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'>
                                            <asp:Image ID="imgFeaturedProduct" runat="server" CssClass="card-img-top" />
                                        </asp:HyperLink>
                                        <div class="position-absolute top-0 start-0 m-3">
                                            <span
                                                class="badge bg-white text-primary shadow-sm px-3 py-2 rounded-pill fw-bold">Featured</span>
                                        </div>
                                    </div>

                                    <div class="card-body d-flex flex-column p-4">

                                        <h5 class="card-title mb-2">
                                            <asp:HyperLink ID="lnkFeaturedProductTitle" runat="server"
                                                NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'
                                                CssClass="text-decoration-none text-dark stretched-link fw-bold d-block text-truncate"
                                                ToolTip='<%# Eval("Name") %>'>
                                                <%# Eval("Name") %>
                                            </asp:HyperLink>
                                        </h5>

                                        <p class="card-text text-muted small mb-3 text-clamp-2">
                                            <asp:Label ID="lblFeaturedDescription" runat="server"
                                                Text='<%# Eval("Description") %>' ToolTip='<%# Eval("Description") %>'>
                                            </asp:Label>
                                        </p>

                                        <div
                                            class="d-flex justify-content-between align-items-center mt-auto pt-3 border-top">
                                            <span class="h5 mb-0 fw-bold text-primary">$<%# Eval("Price", "{0:0.00}" )
                                                    %></span>

                                            <div style="z-index: 2; position: relative;">
                                                <asp:HyperLink ID="lnkBestSellerProductTitle" runat="server"
                                                    NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'
                                                    CssClass="btn btn-outline-primary rounded-pill px-4">
                                                    Add
                                                </asp:HyperLink>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Label ID="lblNoFeaturedProducts" runat="server" CssClass="text-center text-muted mt-3 d-block"
                    Visible="false"></asp:Label>
            </div>
        </section>



        <section class="py-5">
            <div class="container py-4">
                <div class="section-header text-center">
                    <h2 class="display-6">Best Sellers</h2>
                    <p class="fs-5">Top-rated products loved by pet parents</p>
                </div>

                <div class="row g-4" id="bestSellers">
                    <asp:Repeater ID="rptBestSellers" runat="server" OnItemDataBound="rptBestSellers_ItemDataBound">
                        <ItemTemplate>
                            <div class="col-lg-4 col-md-6">
                                <div class="card product-card h-100 shadow-sm">
                                    <div class="product-img-wrapper">
                                        <asp:HyperLink ID="lnkBestSellerProduct" runat="server"
                                            NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'>

                                            <!-- ADDED ImageUrl with ResolveUrl here -->
                                            <asp:Image ID="imgBestSellerProduct" runat="server" CssClass="card-img-top"
                                                ImageUrl='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>' />

                                        </asp:HyperLink>
                                        <div class="position-absolute top-0 start-0 m-3">
                                            <span class="badge bg-warning text-dark rounded-pill shadow-sm px-3 py-2">
                                                <i class="fas fa-star me-1"></i> Top Rated
                                            </span>
                                        </div>
                                    </div>
                                    <div class="card-body d-flex flex-column p-4">
                                        <h5 class="card-title mb-2">
                                            <asp:HyperLink ID="lnkBestSellerProductTitle" runat="server"
                                                NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'
                                                CssClass="text-decoration-none stretched-link text-truncate">
                                                <%# Eval("Name") %>
                                            </asp:HyperLink>
                                        </h5>
                                        <p class="card-text text-muted flex-grow-1 small text-clamp-2">
                                            <asp:Label ID="lblBestSellerDescription" runat="server"></asp:Label>
                                        </p>
                                        <div
                                            class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                                            <span class="product-price">$<%# Eval("Price", "{0:0.00}" ) %></span>
                                            <div style="z-index: 2; position: relative;">

                                                <asp:HyperLink ID="HyperLink1" runat="server"
                                                    NavigateUrl='<%# "~/ProductDetails.aspx?id=" + Eval("Id") %>'
                                                    CssClass="btn-custom-cart">
                                                    Add
                                                </asp:HyperLink>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Label ID="lblNoBestSellers" runat="server" CssClass="text-center text-muted mt-3 d-block"
                    Visible="false"></asp:Label>
            </div>
        </section>

        <section class="testimonial-section py-5">
            <div class="container py-5">
                <div class="section-header text-center text-white">
                    <h2 class="display-6 text-white">Happy Parents</h2>
                    <p class="lead text-white-50">Don't just take our word for it</p>
                </div>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="card testimonial-card h-100 p-4">
                            <div class="card-body text-center">
                                <div class="mb-4 text-warning">
                                    <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                        class="fas fa-star"></i><i class="fas fa-star"></i>
                                </div>
                                <p class="card-text text-white mb-4 fst-italic">"Amazing quality products! My dog loves
                                    the toys we bought here. Fast shipping and excellent customer service."</p>
                                <div class="d-flex align-items-center justify-content-center">
                                    <div class="bg-white text-primary rounded-circle d-flex align-items-center justify-content-center fw-bold"
                                        style="width:40px; height:40px;">S</div>
                                    <div class="text-start ms-3">
                                        <h6 class="mb-0 text-white">Sarah Johnson</h6>
                                        <small class="text-white-50">Dog Owner</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card testimonial-card h-100 p-4">
                            <div class="card-body text-center">
                                <div class="mb-4 text-warning">
                                    <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                        class="fas fa-star"></i><i class="fas fa-star"></i>
                                </div>
                                <p class="card-text text-white mb-4 fst-italic">"Best pet food I've found online. My cat
                                    has never been healthier. Highly recommend this store!"</p>
                                <div class="d-flex align-items-center justify-content-center">
                                    <div class="bg-white text-primary rounded-circle d-flex align-items-center justify-content-center fw-bold"
                                        style="width:40px; height:40px;">M</div>
                                    <div class="text-start ms-3">
                                        <h6 class="mb-0 text-white">Michael Chen</h6>
                                        <small class="text-white-50">Cat Owner</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card testimonial-card h-100 p-4">
                            <div class="card-body text-center">
                                <div class="mb-4 text-warning">
                                    <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                        class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                                </div>
                                <p class="card-text text-white mb-4 fst-italic">"Great variety of products. The website
                                    is easy to navigate and checkout was smooth."</p>
                                <div class="d-flex align-items-center justify-content-center">
                                    <div class="bg-white text-primary rounded-circle d-flex align-items-center justify-content-center fw-bold"
                                        style="width:40px; height:40px;">E</div>
                                    <div class="text-start ms-3">
                                        <h6 class="mb-0 text-white">Emily Rodriguez</h6>
                                        <small class="text-white-50">Pet Lover</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="stats-section shadow-sm">
            <div class="container py-5">
                <div class="row text-center g-4">
                    <div class="col-md-3 col-6">
                        <div class="mb-3 text-primary">
                            <i class="fas fa-users fa-3x"></i>
                        </div>
                        <h3 class="fw-bold mb-1">10,000+</h3>
                        <p class="text-muted small text-uppercase fw-bold ls-1">Happy Customers</p>
                    </div>
                    <div class="col-md-3 col-6 border-start">
                        <div class="mb-3 text-primary">
                            <i class="fas fa-box fa-3x"></i>
                        </div>
                        <h3 class="fw-bold mb-1">5,000+</h3>
                        <p class="text-muted small text-uppercase fw-bold ls-1">Products</p>
                    </div>
                    <div class="col-md-3 col-6 border-start">
                        <div class="mb-3 text-primary">
                            <i class="fas fa-star fa-3x"></i>
                        </div>
                        <h3 class="fw-bold mb-1">4.9/5</h3>
                        <p class="text-muted small text-uppercase fw-bold ls-1">Rating</p>
                    </div>
                    <div class="col-md-3 col-6 border-start">
                        <div class="mb-3 text-primary">
                            <i class="fas fa-shipping-fast fa-3x"></i>
                        </div>
                        <h3 class="fw-bold mb-1">24/7</h3>
                        <p class="text-muted small text-uppercase fw-bold ls-1">Support</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="cta-section text-white py-5">
            <div class="container text-center py-5">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <h2 class="display-5 fw-bold mb-4">Ready to Spoil Your Pet?</h2>
                        <p class="lead mb-5 text-white-50">Join thousands of happy pet parents who trust us with their
                            furry friends' needs.</p>
                        <div class="d-flex flex-wrap justify-content-center gap-3">
                            <asp:Button ID="btnStartShopping" runat="server" Text="Start Shopping"
                                CssClass="btn btn-light btn-lg px-5 rounded-pill fw-bold shadow"
                                OnClick="btnStartShopping_Click" />
                            <asp:Button ID="btnJoinNewsletter" runat="server" Text="Join Newsletter"
                                CssClass="btn btn-outline-light btn-lg px-5 rounded-pill fw-bold"
                                OnClick="btnJoinNewsletter_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <style>
            /* Floating Animation for Hero Icon */
            @keyframes float {
                0% {
                    transform: translateY(0px);
                }

                50% {
                    transform: translateY(-15px);
                }

                100% {
                    transform: translateY(0px);
                }
            }
        </style>

    </asp:Content>