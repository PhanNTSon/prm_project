import docx

def main():
    file_path = "reports/SAP341_Project_Report_Generated.docx"
    print(f"Post-processing: Adding grid borders to tables in {file_path}")
    
    try:
        doc = docx.Document(file_path)
        
        # Iterate through all tables and set style to 'Table Grid'
        for i, table in enumerate(doc.tables):
            table.style = 'Table Grid'
            print(f"Applied 'Table Grid' style to table {i+1}")
            
        doc.save(file_path)
        print("Post-processing completed successfully!")
    except Exception as e:
        print(f"Error during post-processing: {e}")

if __name__ == "__main__":
    main()
