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
            
        # Iterate through inline shapes (images) and scale down if too large
        max_width = Cm(16) # Approx max width for A4 with normal margins
        for i, shape in enumerate(doc.inline_shapes):
            if shape.width > max_width:
                ratio = max_width / shape.width
                shape.width = max_width
                shape.height = int(shape.height * ratio)
                print(f"Resized image {i+1} to fit page width")

        doc.save(file_path)
        print("Post-processing completed successfully!")
    except Exception as e:
        print(f"Error during post-processing: {e}")

if __name__ == "__main__":
    main()
