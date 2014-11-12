Utils = require 'lib/Utils'

width = Utils.getViewportWidth()
height = Utils.getViewportHeight()

module.exports =
  start: "<?xml version='1.0' encoding='utf-8'?>
    <!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>
    <svg version='1.1' id='Layer_1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px'
       width='#{width}' height='#{height-100}' viewBox='0 0 200 340' enable-background='new 0 0 200 340' xml:space='preserve'>
  "
  cosmic:
    tail: '<g>
      <defs>
        <path id="SVGID_1_" d="M39.23,93.292c0,21.206,17.191,38.397,38.398,38.397c0.943,0,1.877-0.046,2.803-0.112l1.938,16.884
          c-7.961,6.941-18.373,11.146-29.768,11.146c-25.03,0-45.318-20.289-45.318-45.319c0-23.375,17.697-42.614,40.429-45.053
          C42.41,75.816,39.23,84.18,39.23,93.292z"/>
      </defs>
      <clipPath id="SVGID_2_">
        <use xlink:href="#SVGID_1_"  overflow="visible"/>
      </clipPath>
      <path clip-path="url(#SVGID_2_)" fill="#FF694F" d="M39.23,93.292c0,21.206,17.191,38.397,38.398,38.397
        c0.943,0,1.877-0.046,2.803-0.112l1.938,16.884c-7.961,6.941-18.373,11.146-29.768,11.146c-25.03,0-45.318-20.289-45.318-45.319
        c0-23.375,17.697-42.614,40.429-45.053C42.41,75.816,39.23,84.18,39.23,93.292z"/>
      <path clip-path="url(#SVGID_2_)" fill="#FFDA00" d="M105.92,107.549c6.486-22.652-22.463-41.685-47.781-40.534
        c-25.318,1.152-44.971,21.169-43.9,44.708c1.072,23.536,20.907,41.683,46.227,40.532C85.783,151.104,99.596,129.638,105.92,107.549
        z"/>
      <path clip-path="url(#SVGID_2_)" fill="#9DEB00" d="M105.342,105.559c3.727-21.574-18.576-39.641-41.496-39.641
        c-22.918,0-41.496,17.747-41.496,39.641c0,21.893,18.614,40.943,41.459,39.119C86.59,142.861,101.408,128.343,105.342,105.559z"/>
      <path clip-path="url(#SVGID_2_)" fill="#00B5FF" d="M108.455,99.397c0-20.638-17.239-37.37-38.506-37.37
        c-21.268,0-38.508,16.732-38.508,37.37c0,20.642,15.123,38.54,38.508,37.374C91.189,135.713,108.455,120.039,108.455,99.397z"/>
    </g>'
    hair: '<path fill="#ADD3D8" d="M100.969,130.564c0,0-13.408-44.962,32.723-62.344c-11.432-7.075-45.986,4.594-46.795,28.902
      C86.086,121.434,93.684,126.858,100.969,130.564z"/>
    <g>
      <defs>
        <path id="SVGID_3_" d="M92.488,106.506c0-21.207,17.192-38.398,38.4-38.398c0.943,0,1.877,0.047,2.803,0.113l1.938-16.884
          c-7.963-6.941-18.375-11.145-29.768-11.145c-25.03,0-45.32,20.288-45.32,45.318c0,23.376,17.699,42.613,40.428,45.054
          C95.67,123.98,92.488,115.615,92.488,106.506z"/>
      </defs>
      <clipPath id="SVGID_4_">
        <use xlink:href="#SVGID_3_"  overflow="visible"/>
      </clipPath>
      <path clip-path="url(#SVGID_4_)" fill="#FF694F" d="M92.488,106.506c0-21.207,17.192-38.398,38.4-38.398
        c0.943,0,1.877,0.047,2.803,0.113l1.938-16.884c-7.963-6.941-18.375-11.145-29.768-11.145c-25.03,0-45.32,20.288-45.32,45.318
        c0,23.376,17.699,42.613,40.428,45.054C95.67,123.98,92.488,115.615,92.488,106.506z"/>
      <path clip-path="url(#SVGID_4_)" fill="#FFDA00" d="M159.18,92.247c6.486,22.654-22.463,41.687-47.78,40.535
        c-25.318-1.151-44.972-21.17-43.901-44.706c1.072-23.539,20.906-41.687,46.227-40.533
        C139.041,48.695,152.855,70.158,159.18,92.247z"/>
      <path clip-path="url(#SVGID_4_)" fill="#9DEB00" d="M158.602,94.24c3.727,21.573-18.578,39.64-41.496,39.64
        s-41.496-17.747-41.496-39.64c0-21.896,18.613-40.944,41.459-39.121C139.848,56.935,154.668,71.454,158.602,94.24z"/>
      <path clip-path="url(#SVGID_4_)" fill="#00B5FF" d="M161.713,100.397c0,20.642-17.24,37.374-38.504,37.374
        c-21.268,0-38.508-16.732-38.508-37.374c0-20.64,15.125-38.537,38.508-37.371C144.448,64.085,161.713,79.758,161.713,100.397z"/>
    </g>'
    body: '<g>
      <path fill="#ADD3D8" d="M93.707,100.969c-25.937,0-46.961,25.771-46.961,57.564v167.251h25.193V193.263
        c0-14.734,9.742-26.68,21.768-26.68c12.018,0,21.764,11.945,21.764,26.68v132.521h25.191V158.533
        C140.662,126.74,119.639,100.969,93.707,100.969z"/>
      <path fill="#E9EAEB" d="M132.681,156.306c2.435,1.118,4.196,4.179,4.196,7.821c0,3.646-1.762,6.705-4.196,7.823
        c-2.437-1.118-4.2-4.178-4.2-7.823C128.48,160.484,130.244,157.424,132.681,156.306z"/>
      <path fill="#44777C" d="M146.838,220.505c-18.357,12.45-31.504,10.073-31.504,10.073s0-28.283,0-39.958
        c0-1.309-0.469-3.632-1.104-5.637c-0.47-1.485,1.104-5.965,1.104-5.965l31.957-7.068
        C147.291,171.95,161.063,210.861,146.838,220.505z"/>
      <path fill="#44777C" d="M88.947,230.578c-15.574,0-42.201-22.464-42.201-50.174c0-27.713,12.625-50.175,28.199-50.175"/>
      <path fill="#FFFFFF" d="M112.74,100.969c-25.934,0-46.957,25.771-46.957,57.564v167.251h25.191V193.263
        c0-14.734,9.746-26.68,21.766-26.68c12.023,0,21.766,11.945,21.766,26.68v132.521h25.193V158.533
        C159.699,126.74,138.674,100.969,112.74,100.969z"/>
      <path fill="#FFFFFF" d="M108.66,103.969c-4.699-1.938-9.725-3-14.953-3c-25.937,0-46.961,25.771-46.961,57.564v23.232
        c10.822,1.544,19.227,12.804,19.227,26.485v117.533h25.193V158.533L108.66,103.969z"/>
      <path fill="#81AFB5" d="M112.74,166.583c12.023,0,21.766,11.945,21.766,26.68v7.895c9.549-3.689,18.117-9.345,25.193-16.486
        v-26.138c0-31.793-21.025-57.564-46.959-57.564"/>
      <path fill="#FFFFFF" d="M150.9,51.227l3.805-23.186c-6.461,5.796-13.998,13.765-19.063,23.186h-46.1
        c-5.063-9.421-12.602-17.39-19.063-23.186l13.189,80.336c0.014-0.025,0.031-0.052,0.045-0.078l7.584,46.236
        c-2.689,2.283-4.402,5.684-4.402,9.487c0,5.248,3.252,9.729,7.848,11.56c3.107,6.802,9.955,11.537,17.92,11.537
        c7.967,0,14.814-4.735,17.924-11.537c4.594-1.831,7.844-6.312,7.844-11.56c0-3.804-1.711-7.204-4.402-9.487l16.947-103.309H150.9z"
        />
      <path fill="#81AFB5" d="M100.84,164.127c0,4.586-2.772,8.304-6.195,8.304c-3.42,0-6.191-3.718-6.191-8.304
        c0-4.583,2.771-8.302,6.191-8.302C98.067,155.825,100.84,159.544,100.84,164.127z"/>
      <path fill="#44777C" d="M99.387,164.127c0-4.249-2.393-7.715-5.467-8.202c0.24-0.038,0.477-0.1,0.725-0.1
        c3.423,0,6.195,3.719,6.195,8.302c0,4.586-2.772,8.304-6.195,8.304c-0.248,0-0.484-0.061-0.725-0.099
        C96.994,171.844,99.387,168.381,99.387,164.127z"/>
      <path fill="#FFFFFF" d="M96.848,166.02c0,3.537-1.646,6.411-3.683,6.411c-2.034,0-3.685-2.874-3.685-6.411
        c0-3.542,1.65-6.413,3.685-6.413C95.201,159.606,96.848,162.478,96.848,166.02z"/>
      <path fill="#ADD3D8" d="M120.432,172.018c-0.174,8.387-3.922,12.802-6.503,15.054c7.421-0.472,13.716-5.051,16.659-11.489
        c4.594-1.831,7.844-6.312,7.844-11.56c0-3.804-1.711-7.204-4.402-9.487l11.996-73.126c-1.029-0.618-1.674-3.231-2.801-3.231
        c-12.588,0-22.793,20.109-22.793,46.974V172.018z"/>
      <path fill="#81AFB5" d="M124.488,164.127c0,4.586,2.775,8.304,6.197,8.304c3.418,0,6.191-3.718,6.191-8.304
        c0-4.583-2.773-8.302-6.191-8.302C127.264,155.825,124.488,159.544,124.488,164.127z"/>
      <path fill="#44777C" d="M125.942,164.127c0-4.249,2.394-7.715,5.469-8.202c-0.243-0.038-0.478-0.1-0.726-0.1
        c-3.422,0-6.197,3.719-6.197,8.302c0,4.586,2.775,8.304,6.197,8.304c0.248,0,0.482-0.061,0.726-0.099
        C128.336,171.844,125.942,168.381,125.942,164.127z"/>
      <path fill="#E6F2F2" d="M135.82,166.02c0,3.537-1.648,6.411-3.684,6.411c-2.033,0-3.684-2.874-3.684-6.411
        c0-3.542,1.65-6.413,3.684-6.413C134.172,159.606,135.82,162.478,135.82,166.02z"/>
      <rect x="134.506" y="306.595" fill="#81AFB5" width="25.193" height="19.189"/>
      <rect x="115.354" y="306.595" fill="#44777C" width="19.152" height="19.189"/>
      <rect x="65.899" y="306.595" fill="#81AFB5" width="25.192" height="19.189"/>
      <rect x="46.746" y="306.595" fill="#44777C" width="19.153" height="19.189"/>
    </g>'
    eyes: '<g>
      <circle fill="#44777C" cx="82.837" cy="85.953" r="6.418"/>
      <circle fill="#C5D8D9" cx="84.727" cy="84.819" r="2.604"/>
      <circle fill="#C5D8D9" cx="82.836" cy="89.097" r="1.178"/>
      <circle fill="#C5D8D9" cx="81.038" cy="86.801" r="0.621"/>
    </g>
    <g>
      <circle fill="#44777C" cx="142.047" cy="84.483" r="6.418"/>
      <circle fill="#C5D8D9" cx="143.938" cy="83.35" r="2.604"/>
      <circle fill="#C5D8D9" cx="142.047" cy="87.627" r="1.178"/>
      <circle fill="#C5D8D9" cx="140.248" cy="85.331" r="0.621"/>
    </g>'
    horn: '<g>
      <circle fill="#ADD3D8" cx="110.265" cy="85.952" r="9.485"/>
      <path fill="#81AFB5" d="M102.793,85.249l7.471-76.237l7.471,76.237c0,4.124-3.344,7.47-7.471,7.47S102.793,89.373,102.793,85.249z"
        />
      <path fill="#44777C" d="M110.264,9.012l7.471,76.237c0,4.124-3.344,7.47-7.471,7.47"/>
    </g>'
  end: '</svg>'
