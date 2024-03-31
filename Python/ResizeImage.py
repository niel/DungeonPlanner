from PIL import Image
import os

imageSize = 256

if __name__ == "__main__":
  directory = "../Images/Mh07Inn"
  file_names = os.listdir(directory)
  for file_name in file_names:
    if file_name.endswith(".import"):
      continue
    img = Image.open(directory + "/" + file_name)
    img = img.resize((imageSize, imageSize))
    img.save(directory + "/" + file_name)
