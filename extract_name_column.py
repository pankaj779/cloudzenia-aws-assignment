#!/usr/bin/env python3
"""
Script to extract the 'Name' column from a CSV file and save it to a new CSV file.
"""

import pandas as pd
import sys
import os


def extract_name_column(input_file, output_file=None):
    """
    Extract the 'Name' column from a CSV file and save it to a new CSV file.
    
    Args:
        input_file (str): Path to the input CSV file
        output_file (str, optional): Path to the output CSV file. 
                                    If not provided, defaults to 'name_column.csv'
    """
    # Check if input file exists
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)
    
    try:
        # Read the CSV file
        print(f"Reading CSV file: {input_file}")
        df = pd.read_csv(input_file)
        
        # Check if 'Name' column exists
        if 'Name' not in df.columns:
            print(f"Error: 'Name' column not found in the CSV file.")
            print(f"Available columns: {', '.join(df.columns.tolist())}")
            sys.exit(1)
        
        # Extract the 'Name' column
        name_df = df[['Name']]
        
        # Set output file name if not provided
        if output_file is None:
            output_file = 'name_column.csv'
        
        # Save to new CSV file
        name_df.to_csv(output_file, index=False)
        print(f"Successfully extracted 'Name' column to '{output_file}'")
        print(f"Total rows extracted: {len(name_df)}")
        
    except pd.errors.EmptyDataError:
        print(f"Error: The CSV file '{input_file}' is empty.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: An unexpected error occurred: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    # Get input file from command line argument or use default
    if len(sys.argv) < 2:
        print("Usage: python extract_name_column.py <input_csv_file> [output_csv_file]")
        print("Example: python extract_name_column.py data.csv name_column.csv")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    extract_name_column(input_file, output_file)

