import docx
from docx.shared import Cm

def main():
    file_path = "reports/SAP341_Project_Report_Generated.docx"
    print(f"Post-processing: Adding grid borders to tables in {file_path}")
    
    try:
        doc = docx.Document(file_path)
        
        # Iterate through all tables and set style to 'Table Grid'
        for i, table in enumerate(doc.tables):
            table.style = 'Table Grid'
            print(f"Applied 'Table Grid' style to table {i+1}")
            
        # Iterate through inline shapes (images) and adjust size
        max_width = Cm(16) # Approx max width for A4 with normal margins
        max_height = Cm(22.2) # Approx 75% of A4 page height (29.7cm * 0.75)
        
        for i, shape in enumerate(doc.inline_shapes):
            # Scale to max_width first
            ratio = max_width / shape.width
            new_width = max_width
            new_height = shape.height * ratio
            
            # If height exceeds max_height, scale down further to fit height limit
            if new_height > max_height:
                ratio = max_height / new_height
                new_height = max_height
                new_width = new_width * ratio
                
            shape.width = int(new_width)
            shape.height = int(new_height)
            print(f"Resized image {i+1} (Width: {shape.width}, Height: {shape.height})")

        doc.save(file_path)
        print("Post-processing completed successfully!")
    except Exception as e:
        print(f"Error during post-processing: {e}")

if __name__ == "__main__":
    main()
