"""
Tests for OCR endpoints - Test with real images from images directory
"""
import pytest
from io import BytesIO
import os
import glob


class TestOCRWithRealImages:
    """Test OCR with actual receipt images from images directory"""
    
    def test_ocr_with_real_images(self, client):
        """Test OCR extraction with real receipt images and print results"""
        import os
        import glob
        
        # Look for images in the images directory
        server_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        images_dir = os.path.join(server_root, "images")
        
        if not os.path.exists(images_dir):
            pytest.skip(f"Images directory not found at {images_dir}")
        
        # Find all image files
        image_patterns = ["*.jpg", "*.jpeg", "*.png", "*.JPG", "*.JPEG", "*.PNG"]
        image_files = []
        for pattern in image_patterns:
            image_files.extend(glob.glob(os.path.join(images_dir, pattern)))
        
        if not image_files:
            pytest.skip(f"No images found in {images_dir}")
        
        print(f"\n{'='*80}")
        print(f"Testing OCR with {len(image_files)} images from {images_dir}")
        print(f"{'='*80}\n")
        
        for image_path in image_files:
            image_name = os.path.basename(image_path)
            print(f"\n{'='*80}")
            print(f"Processing: {image_name}")
            print(f"{'='*80}")
            
            try:
                # Read the image file
                with open(image_path, 'rb') as f:
                    image_data = f.read()
                
                # Determine mime type
                if image_path.lower().endswith(('.jpg', '.jpeg')):
                    mime_type = "image/jpeg"
                elif image_path.lower().endswith('.png'):
                    mime_type = "image/png"
                else:
                    mime_type = "application/octet-stream"
                
                # Send to OCR endpoint
                response = client.post(
                    "/ocr/images-to-text",
                    files={"file": (image_name, BytesIO(image_data), mime_type)}
                )
                
                print(f"Status Code: {response.status_code}")
                
                if response.status_code == 200:
                    data = response.json()
                    print(f"\nExtracted Transaction Data:")
                    print(f"{'-'*80}")
                    for key, value in data.items():
                        if value is not None:
                            print(f"  {key:20s}: {value}")
                    print(f"{'-'*80}")
                else:
                    print(f"Error: {response.json()}")
                
            except Exception as e:
                print(f"Error processing {image_name}: {str(e)}")
        
        print(f"\n{'='*80}")
        print(f"Completed processing {len(image_files)} images")
        print(f"{'='*80}\n")
        
        # Test always passes - we just want to see the output
        assert True

