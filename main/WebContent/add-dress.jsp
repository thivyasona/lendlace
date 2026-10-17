<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Add New Dress</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>

*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:'Poppins',sans-serif;
}

body{
background:#f5f5f5;
}

.navbar{
background:#6A1B9A;
}

.card{
border:none;
border-radius:20px;
box-shadow:0 8px 20px rgba(0,0,0,.10);
padding:30px;
}

.preview{
width:220px;
height:300px;
object-fit:cover;
border-radius:15px;
border:3px solid #6A1B9A;
}

</style>

</head>

<body>

<nav class="navbar navbar-dark">

<div class="container">

<a href="owner-dashboard.jsp" class="navbar-brand">

<i class="bi bi-arrow-left-circle"></i>

Add New Dress

</a>

</div>

</nav>

<div class="container py-5">

<div class="card">

<h2 class="mb-4">

Add Dress

</h2>
<form action="addDress" method="post" enctype="multipart/form-data">

<div class="text-center mb-4">

<img id="preview"
src="https://via.placeholder.com/220x300?text=Dress"
class="preview">

<input
type="file"
id="dressImage"
name="dressImage"
class="form-control mt-3"
accept="image/*">

</div>

<div class="row">

<div class="col-md-6 mb-3">

<label>Dress Name</label>

<input
type="text"
id="dressName"
name="dressName"
class="form-control"
required>

</div>

<div class="col-md-6 mb-3">
<label>Brand</label>
<input
type="text"
id="brand"
name="brand"
class="form-control"
required>
</div>
<div class="col-md-6 mb-3">
<label>Category</label>
<select id="category" name="category" class="form-select">
<option>Bridal Wear</option>
<option>Reception Wear</option>
<option>Party Wear</option>
<option>Saree</option>
<option>Lehenga</option>
<option>Gown</option>
</select>
</div>
<div class="col-md-6 mb-3">
<label>Rental Price Per Day</label>
<input
type="number"
id="dressPrice"
name="dressPrice" min="1" step="0.01" required placeholder="Enter rental price per day"
class="form-control"
required>
</div>
<div class="col-md-6 mb-3">
<label>Available From</label>
<input
type="date"
id="availableFrom"
name="availableFrom"
class="form-control"
required>
</div>
<div class="col-md-6 mb-3">
<label>Available Until</label>
<input
type="date"
id="availableTo"
name="availableTo"
class="form-control"
required>
</div>
<div class="col-md-6 mb-3">
<label>Security Deposit</label>
<input
type="number"
id="deposit"
name="deposit"
class="form-control"
required>
</div>
<div class="col-md-6 mb-3">
<label>Size</label>
<div>
<label><input type="checkbox" class="size" name="size" value="S"> S</label><br>
<label><input type="checkbox" class="size" name="size" value="M"> M</label><br>
<label><input type="checkbox" class="size" name="size" value="L"> L</label><br>
<label><input type="checkbox" class="size" name="size" value="XL"> XL</label>

</div>

</div>

<div class="col-md-6 mb-3">

<label>Color</label>

<input
type="text"
id="color"
name="color"
class="form-control">

</div>

<div class="col-md-6 mb-3">

<label>Occasion</label>

<input
type="text"
id="occasion"
name="occasion"
class="form-control">

</div>

<div class="col-md-6 mb-3">

<label>Status</label>

<select
id="status"
name="status"
class="form-select">

<option>Available</option>
<option>Not Available</option>

</select>

</div>

<div class="col-12 mb-3">

<label>Description</label>

<textarea
id="description"
name="description"
class="form-control"
rows="4"></textarea>
</div>
<div class="d-grid">

<button
type="submit"
class="btn btn-primary btn-lg">
Upload Dress
</button>
</div>
</form>
</div>
</div>
<script>
// Dress add/edit is handled server-side by /addDress (MySQL).
// Image preview only:
document.getElementById("dressImage").addEventListener("change", function(){
    if (this.files && this.files[0]) {
        const reader = new FileReader();
        reader.onload = e => document.getElementById("preview").src = e.target.result;
        reader.readAsDataURL(this.files[0]);
    }
});
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>